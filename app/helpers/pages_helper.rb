module PagesHelper
  
  def basecamp_session
    config = YAML.load_file(File.join(RAILS_ROOT,'config','basecamp.yml'))['basecamp']
    @session = Basecamp.new(config['url'],config['user'],config['pass'])
    @completed = @session.lists(config['project_id'], true).collect{|list| @session.get_list(list.id)}
    @uncompleted = @session.lists(config['project_id'], false).collect{|list| @session.get_list(list.id)}    
  end
    
  # proper date format for google sitemaps
  def w3c_date(date)
    date.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
  end
  
  
end
