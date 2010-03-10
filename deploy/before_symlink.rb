# A hook to get all our config in the right place
['alonetone.yml','database.yml','amazon_s3.yml','defensio.yml', 'newrelic.yml'].each do |config_file|
  run "echo 'release_path: #{release_path}/config/#{config_file}' >> #{shared_path}/#{config_file}"
  run "ln -nfs #{shared_path}/shared/config/#{config_file} #{release_path}/shared/#{config_file}"
end