class User < ApplicationRecord
  has_secure_password

  has_many :enrollments, dependent: :destroy
  has_many :courses, through: :enrollments
  has_many :session_progresses, dependent: :destroy

  before_validation { self.email = email.to_s.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
