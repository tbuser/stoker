module CooksHelper
  def cook_status(cook)
    case cook.status
    when "Not Started"
      '<span class="message">Not Started</span>'
    when "Running"
      '<span class="notice">Running</span>'
    when "Finished"
      '<strong><em>Finished</em></strong>'
    else
      '<span class="warning">Unknown</span>'
    end
  end
end
