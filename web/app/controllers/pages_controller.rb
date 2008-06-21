class PagesController < ApplicationController
  
  def show
    respond_to do |format|
      format.html { redirect_to stokers_path }
      format.iphone
    end
  end
  
end
