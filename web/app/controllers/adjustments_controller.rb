class AdjustmentsController < ApplicationController
  before_filter :get_cook
  before_filter :get_adjustment, :except => [:index, :new, :create]

  def index
    @adjustments = Adjustment.find(:all)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @adjustments }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => @adjustment }
    end
  end

  def new
    @adjustment = @cook.adjustments.build
    if @sensor = @cook.stoker.sensors.find(params[:sensor_id])
      @adjustment.sensor  = @sensor
      @adjustment.target  = @sensor.target
      @adjustment.alarm   = @sensor.alarm
      @adjustment.high    = @sensor.high
      @adjustment.low     = @sensor.low
      @adjustment.blower  = @sensor.blower
    end

    respond_to do |format|
      format.html
      format.xml  { render :xml => @adjustment }
    end
  end

  def create
    @adjustment = @cook.adjustments.build(params[:adjustment])

    respond_to do |format|
      if @adjustment.save
        flash[:notice] = 'Adjustment was successfully created.'
        format.html { redirect_to(@cook) }
        format.xml  { render :xml => @adjustment, :status => :created, :location => @adjustment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @adjustment.errors, :status => :unprocessable_entity }
      end
    end
  end

  private
  
  def get_cook
    @cook = Cook.find(params[:cook_id])
  end
  
  def get_adjustment
    @adjustment = @cook.adjustment.find(params[:id])
  end
end
