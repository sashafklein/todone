class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  def authenticate_signed_in!
    unless signed_in?
      flash[:error] = "Please sign in first."
      redirect_to root_path
    end
  end

  def authenticate_user!
    unless current_user.admin? || current_user == User.find(id)
      flash[:error] = "That's not your #{page}!"
      redirect_to root_path
    end
  end

  def authenticate_admin!
    unless current_user.admin?
      flash[:error] = "Only admins can view that page!"
      redirect_to root_path
    end
  end

  private

    def id
      profile? ? params[:user_id] : params[:id]
    end

    def page
      profile? ? "profile" : "list"
    end

    def profile?
      params[:user_id]
    end

end
