class CooksController < ApplicationController
  # GET /cooks
  # GET /cooks.xml
  def index
    @cooks = Cook.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cooks }
    end
  end

  # GET /cooks/1
  # GET /cooks/1.xml
  def show
    @cook = Cook.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cook }
    end
  end

  # GET /cooks/new
  # GET /cooks/new.xml
  def new
    @cook = Cook.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cook }
    end
  end

  # GET /cooks/1/edit
  def edit
    @cook = Cook.find(params[:id])
  end

  # POST /cooks
  # POST /cooks.xml
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

  # PUT /cooks/1
  # PUT /cooks/1.xml
  def update
    @cook = Cook.find(params[:id])

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

  # DELETE /cooks/1
  # DELETE /cooks/1.xml
  def destroy
    @cook = Cook.find(params[:id])
    @cook.destroy

    respond_to do |format|
      format.html { redirect_to(cooks_url) }
      format.xml  { head :ok }
    end
  end
end
