class BlowersController < ApplicationController
  # GET /blowers
  # GET /blowers.xml
  def index
    @blowers = Blower.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @blowers }
      format.iphone { render :layout => false }
    end
  end

  # GET /blowers/1
  # GET /blowers/1.xml
  def show
    @blower = Blower.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @blower }
    end
  end

  # GET /blowers/new
  # GET /blowers/new.xml
  def new
    @blower = Blower.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @blower }
    end
  end

  # GET /blowers/1/edit
  def edit
    @blower = Blower.find(params[:id])
  end

  # POST /blowers
  # POST /blowers.xml
  def create
    @blower = Blower.new(params[:blower])

    respond_to do |format|
      if @blower.save
        flash[:notice] = 'Blower was successfully created.'
        format.html { redirect_to(@blower) }
        format.xml  { render :xml => @blower, :status => :created, :location => @blower }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @blower.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /blowers/1
  # PUT /blowers/1.xml
  def update
    @blower = Blower.find(params[:id])

    respond_to do |format|
      if @blower.update_attributes(params[:blower])
        flash[:notice] = 'Blower was successfully updated.'
        format.html { redirect_to(@blower) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @blower.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /blowers/1
  # DELETE /blowers/1.xml
  def destroy
    @blower = Blower.find(params[:id])
    @blower.destroy

    respond_to do |format|
      format.html { redirect_to(blowers_url) }
      format.xml  { head :ok }
    end
  end
end
