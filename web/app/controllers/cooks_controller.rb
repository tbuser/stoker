class CooksController < ApplicationController
  before_filter :find_cook, :except => [:index, :new, :create]
  
  def index
    @cooks = Cook.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cooks }
      format.iphone { render :layout => false }
    end
  end

  def show
    @adjustments = @cook.adjustments.find(:all, :order => "created_at DESC")
    @refresh = true
    
    params[:range] ||= @cook.running? ? "last" : "all"
    params[:hours] ||= "6"
    
    case params[:range]
    when "last"
      current_time = @cook.running? ? Time.now : @cook.end_time
      params[:start_time] = current_time - params[:hours].to_i.hours >= @cook.start_time ? current_time - params[:hours].to_i.hours : @cook.start_time
      params[:end_time]   = current_time
    when "all"
      params[:start_time] = @cook.start_time
      params[:end_time]   = @cook.running? ? Time.now : @cook.end_time
    when "range"
      params[:start_time] = "#{params[:start][:year]}-#{params[:start][:month]}-#{params[:start][:day]} #{params[:start][:hour]}:#{params[:start][:minute]}".to_time
      params[:end_time]   = "#{params[:end][:year]}-#{params[:end][:month]}-#{params[:end][:day]} #{params[:end][:hour]}:#{params[:end][:minute]}".to_time
    end
    
    @events = @cook.stoker.events.find(:all,
      :include => :sensor, 
      :conditions => ["events.created_at BETWEEN ? AND ?", params[:start_time], params[:end_time]],
      :order => "events.created_at DESC"
    )
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cook }
      format.iphone
    end
  end

  def new
    @cook = Cook.new
    @cook.start_time = Time.now

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cook }
    end
  end

  def edit
  end

  def create
    @cook = Cook.new(params[:cook])

    respond_to do |format|
      if @cook.save
        flash[:notice] = 'Cook was successfully created.'
        format.html { redirect_to(@cook) }
        format.xml  { render :xml => @cook, :status => :created, :location => @cook }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @cook.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @cook.update_attributes(params[:cook])
        flash[:notice] = 'Cook was successfully updated.'
        format.html { redirect_to(@cook) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cook.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @cook.destroy

    respond_to do |format|
      format.html { redirect_to(cooks_url) }
      format.xml  { head :ok }
    end
  end

  def stop
    respond_to do |format|
      begin
        @cook.stop!
        
        flash[:notice] = 'Cook has finished.'
        format.html { redirect_to(@cook) }
        format.xml { head :ok }
      rescue Exception => e
        @cook.errors.add_to_base(e.message)
        format.html { render :action => "edit" }
        format.xml { render :xml => @cook.errors, :status => :unprocessable_entity }
      end
    end
  end

  def events
    @events = @cook.events
    
    respond_to do |format|
      format.csv { send_data @events.to_csv(:timestamps => true, :only => [:created_at, :name, :alarm, :temp], :methods => [:name]) }
    end
  end

  private
  
  def find_cook
    @cook = Cook.find(params[:id])
  end
end
