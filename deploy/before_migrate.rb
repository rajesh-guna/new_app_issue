shared_path = node[:opsworks] ? "/data/activities/shared" : config.shared_path
node.override[:rel_path] = node[:opsworks] ? "#{release_path}" : "#{config.release_path}"
Chef::Log.debug "shared_path #{shared_path}"
Chef::Log.debug "node[:rel_path] #{node[:rel_path]}"
#puts ":::::::::::release path is ::: #{node[:rel_path]}"
#puts ":::::::shared path is #{shared_path}"
Chef::Log.debug("************ before setting symlink ************* ")
run "ln -nfs #{shared_path}/config/redis.yml #{node[:rel_path]}/config/redis.yml"
run "ln -nfs #{shared_path}/config/database.yml #{node[:rel_path]}/config/database.yml"
run "ln -nfs #{shared_path}/config/sidekiq.yml #{node[:rel_path]}/config/sidekiq.yml"
run "ln -nfs #{shared_path}/config/aws.yml #{node[:rel_path]}/config/aws.yml"
run "ln -nfs #{shared_path}/config/sqs.yml #{node[:rel_path]}/config/sqs.yml"
run "ln -nfs #{shared_path}/config/s3.yml #{node[:rel_path]}/config/s3.yml"
run "ln -nfs #{shared_path}/config/dalli.yml #{node[:rel_path]}/config/dalli.yml"
Chef::Log.debug("************ after after migrate ************* ")