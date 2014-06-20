class HomeController < ApplicationController

def index
  if user_signed_in?
    redirect_to options_display_path
  else
    render layout: 'landing_page'
  end
end



end
