module CooksHelper
  def cook_status(cook)
    case cook.status
    when "Not Started"
      '<span style="color:yellow">Not Started</span>'
    when "Running"
      '<span style="color:green">Running</span>'
    when "Finished"
      '<strong><em>Finished</em></strong>'
    else
      '<span style="color:red">Unknown</span>'
    end
  end
end
