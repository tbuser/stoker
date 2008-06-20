class CooksController < ApplicationController
  before_filter :find_cook, :except => [:index, :new, :create]
  
  def index
    @cooks = Cook.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cooks }
    end
  end

  def show
    @recent_food_events = @cook.stoker.events.find(:all,
      :include => :sensor, 
      :conditions => ["events.created_at >= ? AND sensors.alarm <> ?", Time.now - 2.hours, "Fire"],
      :order => "events.created_at DESC"
    )
    
    @recent_fire_events = @cook.stoker.events.find(:all,
      :include => :sensor,
      :conditions => ["events.created_at >= ? AND sensors.alarm = ?", Time.now - 2.hours, "Fire"],
      :order => "events.created_at DESC"
    )
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cook }
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
