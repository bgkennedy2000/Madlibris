class ApplicationController < ActionController::Base
  protect_from_forgery
  layout :layout_by_resource

  protected
  def after_sign_in_path_for(resource)
    root_path #update to games home screen
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
