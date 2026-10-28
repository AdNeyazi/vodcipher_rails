class CourseSession < ApplicationRecord
  STATUSES = %w[processing ready failed].freeze

  belongs_to :course
  has_many :session_progresses, dependent: :destroy

  validates :title, presence: true
  validates :vdocipher_video_id, presence: true
  validates :status, inclusion: { in: STATUSES }

  before_validation { self.vdocipher_video_id = vdocipher_video_id.to_s.strip }

  STATUSES.each do |name|
    define_method(:"#{name}?") { status == name }
  end

  def previous_session
    course.course_sessions.where("position < ?", position).reorder(position: :desc).first
  end

  def next_session
    course.course_sessions.where("position > ?", position).reorder(:position).first
  end
end
