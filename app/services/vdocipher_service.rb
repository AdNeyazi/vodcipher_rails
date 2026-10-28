require "net/http"
require "json"

# Thin client for the VdoCipher REST API.
# The API secret stays on the server: set VDOCIPHER_API_SECRET (or
# credentials: vdocipher.api_secret). It must never reach the browser.
class VdocipherService
  BASE_URL = "https://dev.vdocipher.com/api".freeze

  class Error < StandardError; end

  def initialize(api_secret: nil)
    raw = api_secret.presence ||
        ENV["VDOCIPHER_API_SECRET"].presence ||
        Rails.application.credentials.dig(:vdocipher, :api_secret).presence
    @api_secret = clean_secret(raw)
    raise Error, "VdoCipher API secret is not configured (set VDOCIPHER_API_SECRET)" if @api_secret.blank?
  end

  # Short-lived playback token for one video.
  # Returns { "otp" => "...", "playbackInfo" => "..." }
  # `annotate` is an array of watermark hashes (see VdoCipher dynamic watermark docs).
  def otp(video_id, ttl: 300, annotate: nil)
    body = { ttl: ttl }
    body[:annotate] = annotate.to_json if annotate.present?
    request(Net::HTTP::Post, "/videos/#{video_id}/otp", body: body)
  end

  # Videos in your VdoCipher account (used for the admin dropdown).
  def list_videos(page: 1, limit: 50)
    request(Net::HTTP::Get, "/videos", query: { page: page, limit: limit })
  end

  # Metadata for one video (status, length in seconds, title...).
  def video(video_id)
    request(Net::HTTP::Get, "/videos/#{video_id}")
  end

  # Creates an upload slot. The response contains the new video id and the
  # clientPayload the browser needs to upload the file straight to VdoCipher.
  def create_upload(title)
    request(Net::HTTP::Put, "/videos", query: { title: title })
  end

  private

  def clean_secret(raw)
    raw.to_s.strip.delete_prefix("Apisecret").strip.gsub(/\A["']|["']\z/, "").gsub(/\s+/, "")
  end

  def request(klass, path, query: nil, body: nil)
    uri = URI("#{BASE_URL}#{path}")
    uri.query = URI.encode_www_form(query) if query

    req = klass.new(uri)
    req["Accept"] = "application/json"
    req["Content-Type"] = "application/json"
    req["Authorization"] = "Apisecret #{@api_secret}"
    req.body = body.to_json if body

    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 15) do |http|
      http.request(req)
    end

    unless res.is_a?(Net::HTTPSuccess)
      raise Error, "VdoCipher API #{res.code}: #{res.body.to_s.truncate(300)}"
    end

    JSON.parse(res.body)
  rescue JSON::ParserError
    raise Error, "VdoCipher API returned an unreadable response"
  rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, SystemCallError, OpenSSL::SSL::SSLError => e
    raise Error, "Could not reach VdoCipher (#{e.class})"
  end
end
