# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  before_filter :authenticate, :except => [ :index, :show, :about ]
  before_filter :adjust_format_for_iphone
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '70bf28881f0212351f74cf8d4c78796f'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  private

  def authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == "root" && password == "tini"
    end
  end  
  
  def iphone_user_agent?
    request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/]
  end
  
  def adjust_format_for_iphone    
    request.format = :iphone if iphone_user_agent?
  end  
end
