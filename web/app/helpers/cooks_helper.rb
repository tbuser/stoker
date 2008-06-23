module CooksHelper
  def cook_status(cook)
    case cook.status
    when "Not Started"
      '<span style="color:yellow">Not Started</span>'
    when "Running"
      '<span style="color:green">Running</span>'
    when "Finished"
      'Finished'
    end
  end
end
