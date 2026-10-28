# Shared guard for anything that touches a single session's video.
# Access = admin, OR the session is a free preview, OR the user is enrolled.
module CourseAccess
  extend ActiveSupport::Concern

  included do
    before_action :require_login
    before_action :set_course_and_session
    before_action :require_access!
  end

  private

  def set_course_and_session
    @course = Course.find(params[:course_id])
    @course_session = @course.course_sessions.find(params[:course_session_id] || params[:id])
  end

  def require_access!
    return if current_user.admin? || @course_session.preview? || @course.enrolled?(current_user)

    if request.format.json?
      render json: { error: "Enroll in this course to watch" }, status: :forbidden
    else
      redirect_to @course, alert: "Enroll in this course to watch its sessions."
    end
  end
end
