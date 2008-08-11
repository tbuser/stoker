class StokersController < ApplicationController
  before_filter :find_stoker, :except => [:index, :new, :create, :toggle_alarm]
  
  def index
    @stokers = Stoker.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stokers }
      format.iphone { render :layout => false }
    end
  end

  def show
    @recent_events = @stoker.events.find(:all, :order => "created_at DESC", :conditions => ["created_at >= ?", Time.now - 2.hours])
    @process_status = running_pids.include?(@stoker.pid) ? "Running" : "Stopped"
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @stoker }
      format.iphone { render :layout => false }
    end
  end

  def new
    @stoker = Stoker.new
    
    @stoker.connection_type = "http"
    @stoker.port            = 80
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @stoker }
    end
  end

  def edit
  end

  def create
    @stoker = Stoker.new(params[:stoker])

    respond_to do |format|
      if @stoker.save
        flash[:notice] = 'Stoker was successfully created.'
        format.html { redirect_to(@stoker) }
        format.xml  { render :xml => @stoker, :status => :created, :location => @stoker }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @stoker.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @stoker.update_attributes(params[:stoker])
        flash[:notice] = 'Stoker was successfully updated.'
        format.html { redirect_to(@stoker) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @stoker.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @stoker.destroy

    respond_to do |format|
      format.html { redirect_to(stokers_url) }
      format.xml  { head :ok }
    end
  end
  
  def sync
    respond_to do |format|
      begin
        @stoker.sync!
        
        format.html do
          flash[:notice] = "Stoker sensors synchronized"
          redirect_to(@stoker)
        end
        format.xml  { head :ok }
        format.js
      rescue Exception => e
        logger.info("#{e.message}\n#{e.backtrace.to_yaml}")
        flash[:warning] = e.message
        format.html { redirect_to(@stoker) }
        format.xml  { render :xml => @stoker.errors, :status => :unprocessable_entity }
        format.js do
          render :update do |page|
            page << "alert('#{e.message}');"
          end
        end
      end
    end
  end

  def run
    respond_to do |format|
      begin
        spawn do
          while true do
            @stoker.sync!
            sleep 60
          end
        end
        
        # @stoker.run!
        
        format.html { redirect_to(@stoker) }
        format.xml { head :ok }
      rescue Exception => e
        logger.info("#{e.message}\n#{e.backtrace.to_yaml}")
        flash[:warning] = e.message
        format.html { redirect_to(@stoker) }
        format.xml  { render :xml => @stoker.errors, :status => :unprocessable_entity }
      end
    end
  end

  def toggle_alarm
    if session[:mute_alarm]
      session[:mute_alarm] = false
    else
      session[:mute_alarm] = true
    end
    render :update do |page|
      page.replace_html :alarm_sound, :partial => "/shared/alarm_sound", :locals => {:alarm => ""}
    end
  end

  private
  
  def find_stoker
    @stoker = Stoker.find(params[:id])
  end  
end