# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  before_filter :authenticate, :except => [ :index, :show, :about ]
  before_filter :adjust_format_for_iphone
  before_filter :check_background_processes
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '70bf28881f0212351f74cf8d4c78796f'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  private

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == STOKER_CONFIG[:username] && password == STOKER_CONFIG[:password]
    end
  end  
  
  def iphone_user_agent?
    request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/]
  end
  
  def adjust_format_for_iphone    
    request.format = :iphone if iphone_user_agent?
  end  
  
  def running_pids
    if RUBY_PLATFORM =~ /mswin/i
      # TODO: figure out how to get list of processes from windows
    else
      # assume osx or linux
      pids = `ps aux | awk '{print $2}' | grep -v PID`
      pids.split(/\n/).collect{|n| n.to_i}
    end
  end
  
  def check_background_processes
    logger.info("Checking background processes")
    
    # FIXME: for now, we just spawn a new process for every stoker, should
    # just keep one process to update all the stokers that have active cooks...
    Stoker.find(:all).each do |stoker|
      if running_pids.include?(stoker.pid)
        logger.info("Background process for #{stoker.name} already running")
      else
        logger.info("Starting background process for #{stoker.name}")
        begin
          process = spawn do
            while true do
              stoker.reload
              
              if stoker.cooks.active.size > 0
                logger.info("Syncing #{stoker.name}")
                stoker.sync!
              else
                logger.info("No active cooks for #{stoker.name}")
              end
              sleep 60
            end
          end
        
          stoker.pid = process.handle
          stoker.save!
        rescue
          flash[:warning] = "Failed to start background stoker process for #{stoker.name}"
        end
      end
    end
    
  end

end
