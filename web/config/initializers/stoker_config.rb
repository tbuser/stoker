STOKER_CONFIG = {}
config_file = File.join(File.dirname(__FILE__), '../stoker_config.yml')

if File.exists?(config_file)
  YAML::load(File.read(config_file)).each do |k,v|
    STOKER_CONFIG[k] = v
  end
else
  STOKER_CONFIG[:username] = "root"
  STOKER_CONFIG[:password] = "tini"
  STOKER_CONFIG[:google_analytics_uacct] = ""
end
