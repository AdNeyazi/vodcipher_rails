module Admin
  class CourseSessionsController < BaseController
    before_action :set_course
    before_action :set_course_session, only: %i[edit update destroy refresh]
    before_action :load_library, only: %i[new edit create update]

    def new
      @course_session = @course.course_sessions.new(
        position: @course.course_sessions.maximum(:position).to_i + 1
      )
    end

    def create
      @course_session = @course.course_sessions.new(course_session_params)
      if @course_session.save
        redirect_to edit_admin_course_path(@course), notice: "Session added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @course_session.update(course_session_params)
        redirect_to edit_admin_course_path(@course), notice: "Session updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @course_session.destroy
      redirect_to edit_admin_course_path(@course), notice: "Session removed."
    end

    # Asks VdoCipher for the video's current state and stores status + duration.
    def refresh
      info = VdocipherService.new.video(@course_session.vdocipher_video_id)
      @course_session.update!(
        status: status_from(info["status"]),
        duration: info["length"].presence&.to_i || @course_session.duration
      )
      redirect_to edit_admin_course_path(@course),
                  notice: "VdoCipher status: #{info['status'] || 'unknown'}"
    rescue VdocipherService::Error => e
      redirect_to edit_admin_course_path(@course), alert: e.message
    end

    private

    def set_course
      @course = Course.find(params[:course_id])
    end

    def set_course_session
      @course_session = @course.course_sessions.find(params[:id])
    end

    def course_session_params
      params.require(:course_session)
            .permit(:title, :position, :vdocipher_video_id, :status, :preview)
    end

    # Videos already uploaded in the VdoCipher account, offered as suggestions.
    # If the API is unreachable the form still works with a pasted video id.
    def load_library
      @library = VdocipherService.new.list_videos.fetch("rows", [])
    rescue VdocipherService::Error => e
      @library = []
      @library_error = e.message
    end

    def status_from(raw)
      value = raw.to_s.downcase
      return "ready" if value == "ready"
      return "failed" if value.include?("fail") || value.include?("error")

      "processing"
    end
  end
end
