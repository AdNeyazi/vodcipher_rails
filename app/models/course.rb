class Course < ApplicationRecord
  has_many :course_sessions, -> { order(:position, :id) }, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :users, through: :enrollments

  validates :title, presence: true

  def enrolled?(user)
    user.present? && enrollments.exists?(user_id: user.id)
  end

  def total_duration
    course_sessions.sum(:duration)
  end
end
