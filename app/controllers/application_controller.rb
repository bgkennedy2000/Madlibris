class ApplicationController < ActionController::Base
  protect_from_forgery
  layout :layout_by_resource

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path
  end

  protected
  def after_sign_in_path_for(resource)
    options_display_path || root_path
  end

  protected
  def layout_by_resource
    if devise_controller?
      "landing_page"
    else
      "application"
    end
  end

end
