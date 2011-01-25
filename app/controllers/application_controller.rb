class ApplicationController < ActionController::Base
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    if user_signed_in?
        redirect_to unauthorized_url
    else
        redirect_to new_user_session_url
    end
  end
  
  protect_from_forgery
  layout 'application'
end
