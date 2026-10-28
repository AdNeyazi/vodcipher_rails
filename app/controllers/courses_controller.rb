class CoursesController < ApplicationController
  before_action :require_login
  before_action :set_course, only: %i[show enroll]

  def index
    @courses = Course.includes(:course_sessions).order(:title)
    @enrolled_ids = current_user.enrollments.pluck(:course_id)
  end

  def show
    @sessions = @course.course_sessions
    @enrolled = @course.enrolled?(current_user)
    @completed_ids = current_user.session_progresses.where(completed: true).pluck(:course_session_id)
  end

  # Demo enrollment: free, one click. Replace with your payment flow.
  def enroll
    current_user.enrollments.find_or_create_by!(course: @course)
    first = @course.course_sessions.first
    redirect_to(first ? course_course_session_path(@course, first) : @course, notice: "You're enrolled!")
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end
end
