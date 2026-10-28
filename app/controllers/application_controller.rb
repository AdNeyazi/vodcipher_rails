class ApplicationController < ActionController::Base
  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def require_login
    return if current_user

    if request.format.json?
      render json: { error: "Please sign in" }, status: :unauthorized
    else
      redirect_to login_path, alert: "Please sign in first."
    end
  end

  def require_admin
    head :forbidden unless current_user&.admin?
  end
end
