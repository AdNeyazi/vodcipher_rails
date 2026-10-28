class ProgressesController < ApplicationController
  include CourseAccess

  # PATCH /courses/:course_id/course_sessions/:course_session_id/progress
  # Body (JSON): { watched_seconds: 123, completed: false }
  def update
    progress = current_user.session_progresses.find_or_initialize_by(course_session: @course_session)
    progress.watched_seconds = params[:watched_seconds].to_i.clamp(0, 86_400)
    progress.completed = true if ActiveModel::Type::Boolean.new.cast(params[:completed])
    progress.save!
    head :no_content
  end
end
