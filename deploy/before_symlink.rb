# A hook to get all our config in the right place
['alonetone.yml','database.yml','amazon_s3.yml','defensio.yml', 'newrelic.yml'].each do |config_file|
  run "ln -nfs #{shared_path}/config/#{config_file} #{release_path}/config/#{config_file}"
end