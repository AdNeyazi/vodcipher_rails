class CourseSessionsController < ApplicationController
  include CourseAccess

  # HTML page with the player. No OTP is created here; the page asks for one
  # via #otp so it can be refreshed without reloading.
  def show
    @sessions = @course.course_sessions
    @progress = current_user.session_progresses.find_by(course_session: @course_session)
    @completed_ids = current_user.session_progresses.where(completed: true).pluck(:course_session_id)
  end

  # JSON: { otp, playbackInfo } for THIS session's video only.
  def otp
    unless @course_session.ready?
      return render json: { error: "This video is still #{@course_session.status}." }, status: :conflict
    end

    data = VdocipherService.new.otp(
      @course_session.vdocipher_video_id,
      ttl: 300,
      annotate: watermark
    )
    render json: data.slice("otp", "playbackInfo")
  rescue VdocipherService::Error => e
    Rails.logger.error("[VdoCipher] #{e.message}")
    render json: { error: "Video is temporarily unavailable." }, status: :bad_gateway
  end

  private

  # Moving watermark with the viewer's email: discourages sharing/screen recording.
  def watermark
    [{
      type: "rtext",
      text: current_user.email,
      alpha: "0.60",
      color: "0xFF0000",
      size: "15",
      interval: "5000"
    }]
  end
end
