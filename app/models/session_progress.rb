class SessionProgress < ApplicationRecord
  belongs_to :user
  belongs_to :course_session

  validates :user_id, uniqueness: { scope: :course_session_id }
  validates :watched_seconds, numericality: { greater_than_or_equal_to: 0 }
end
