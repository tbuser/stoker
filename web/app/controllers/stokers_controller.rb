class StokersController < ApplicationController
  before_filter :find_stoker, :except => [:index, :new, :create]
  
  # GET /stokers
  # GET /stokers.xml
  def index
    @stokers = Stoker.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stokers }
    end
  end

  # GET /stokers/1
  # GET /stokers/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @stoker }
    end
  end

  # GET /stokers/new
  # GET /stokers/new.xml
  def new
    @stoker = Stoker.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @stoker }
    end
  end

  # GET /stokers/1/edit
  def edit
  end

  # POST /stokers
  # POST /stokers.xml
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

  # PUT /stokers/1
  # PUT /stokers/1.xml
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

  # DELETE /stokers/1
  # DELETE /stokers/1.xml
  def destroy
    @stoker.destroy

    respond_to do |format|
      format.html { redirect_to(stokers_url) }
      format.xml  { head :ok }
    end
  end
  
  def sync
    respond_to do |format|
      if @stoker.sync
        flash[:notice] = "Stoker sensors synchronized"
        format.html { redirect_to(@stoker) }
        format.xml  { head :ok }
      else
        format.html { redirect_to(@stoker) }
        format.xml  { render :xml => @stoker.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def find_stoker
    @stoker = Stoker.find(params[:id])
  end
end
