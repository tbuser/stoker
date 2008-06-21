# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def spinner(id)
    image_tag "spinner.gif", :id => id, :style => "display:none"
  end
  
  def format_date(time, options = {})
    time.to_time.strftime("%Y-%m-%d")
  end

  def format_time(time, options = {})
    time.to_time.strftime("%I:%M#{options[:include_seconds] ? ':%S' : ''} %p")
  end
  
  def format_datetime(time, options = {})
    format_date(time.to_time, options) + ' ' + format_time(time.to_time, options)
  end
  
  def events_to_graph_params(events, container_name)
    data_sets       = {}
    data_set_count  = 0
    data_set_js     = ""
    data_set_names  = []

    events.each do |e|
      data_sets[e.sensor] ||= []
      data_sets[e.sensor] << [e.created_at.to_i, e.temp]
    end


    data_sets.each do |sensor,temps|
      temps_js      = ""
      temp_strings  = []
      data_parts_js = []

      temps.each do |temp|
        temp_strings << "[#{temp[0]}, #{temp[1]}]"
      end

      temps_js = temp_strings.join(", ")
      data_set_js << "d#{data_set_count} = [#{temps_js}];\n    "

      data_parts_js << "data: d#{data_set_count}"
      data_parts_js << "label: '#{sensor.name} #{sensor.temp}F'"

      # data_parts_js << "lines: {fill: true}" if sensor.alarm == "Fire"

      data_set_names << "{#{data_parts_js.join(", ")}}"

      data_set_count += 1
    end

    {
      :container_name => container_name,
      :data_set_js => data_set_js,
      :data_set_names => data_set_names
    }
  end
  
  def graph(events, container_name)
    food_events = events.find_all{|x| x.sensor.alarm != "Fire"}
    fire_events = events.find_all{|x| x.sensor.alarm == "Fire"}
      
    options = []
    options << events_to_graph_params(food_events, container_name)
    options << events_to_graph_params(fire_events, container_name)
    
    options[0][:type] = "Food"
    options[1][:type] = "Fire"
    
    render :partial => "/shared/graphs", :locals => {:options => options}
  end

end
