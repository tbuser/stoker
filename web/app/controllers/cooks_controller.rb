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
    params[:range] ||= @cook.end_time.to_s != "" ? "all" : "last"
    params[:hours] ||= "6"
    
    case params[:range]
    when "last"
      params[:start_time] = Time.now - params[:hours].to_i.hours >= @cook.start_time ? Time.now - params[:hours].to_i.hours : @cook.start_time
      params[:end_time]   = @cook.end_time.to_s == "" ? Time.now : @cook.end_time
    when "all"
      params[:start_time] = @cook.start_time
      params[:end_time]   = @cook.end_time.to_s == "" ? Time.now : @cook.end_time
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
  
  def find_cook
    @cook = Cook.find(params[:id])
  end
end
