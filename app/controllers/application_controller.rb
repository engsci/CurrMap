class ApplicationController < ActionController::Base
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    if user_signed_in?
        redirect_to unauthorized_url
    else
        redirect_to new_user_session_url
    end
  end
  def url_escape(string)
    string.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
    '%' + $1.unpack('H2' * $1.size).join('%').upcase
    end.tr(' ', '+')
  end
  


  protect_from_forgery
  layout 'application'
end
