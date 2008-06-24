class AdjustmentsController < ApplicationController
  # GET /adjustments
  # GET /adjustments.xml
  def index
    @adjustments = Adjustment.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @adjustments }
    end
  end

  # GET /adjustments/1
  # GET /adjustments/1.xml
  def show
    @adjustment = Adjustment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @adjustment }
    end
  end

  # GET /adjustments/new
  # GET /adjustments/new.xml
  def new
    @adjustment = Adjustment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @adjustment }
    end
  end

  # GET /adjustments/1/edit
  def edit
    @adjustment = Adjustment.find(params[:id])
  end

  # POST /adjustments
  # POST /adjustments.xml
  def create
    @adjustment = Adjustment.new(params[:adjustment])

    respond_to do |format|
      if @adjustment.save
        flash[:notice] = 'Adjustment was successfully created.'
        format.html { redirect_to(@adjustment) }
        format.xml  { render :xml => @adjustment, :status => :created, :location => @adjustment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @adjustment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /adjustments/1
  # PUT /adjustments/1.xml
  def update
    @adjustment = Adjustment.find(params[:id])

    respond_to do |format|
      if @adjustment.update_attributes(params[:adjustment])
        flash[:notice] = 'Adjustment was successfully updated.'
        format.html { redirect_to(@adjustment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @adjustment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /adjustments/1
  # DELETE /adjustments/1.xml
  def destroy
    @adjustment = Adjustment.find(params[:id])
    @adjustment.destroy

    respond_to do |format|
      format.html { redirect_to(adjustments_url) }
      format.xml  { head :ok }
    end
  end
end
