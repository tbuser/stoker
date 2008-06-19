# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def spinner(id)
    image_tag "spinner.gif", :id => id, :style => "display:none"
  end
  
  def format_time(time)
    time.strftime("%Y-%m-%d %I:%m:%S %p")
  end
end
