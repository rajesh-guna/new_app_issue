if node[:opsworks]
  require 'aws-sdk'
  # establishing connection with aws to run custom restart of nginx
  awscreds = {
     :access_key_id    => node[:opsworks_access_keys][:access_key_id],
     :secret_access_key => node[:opsworks_access_keys][:secret_access_key],
     :region           => node[:opsworks_access_keys][:opsworks_region]
  }

  #TODO-RAILS3 once migrations is done we can remove setting from stack and bellow code.
  # unless node[:rails3][:use_iam_profile]
  #   awscreds.merge!({
  #     :access_key_id    => node[:opsworks_access_keys][:access_key_id],
  #     :secret_access_key => node[:opsworks_access_keys][:secret_access_key]
  #   })
  # end

  AWS.config(awscreds)

  # intializing the opsworks client object
  opsworks = AWS::OpsWorks::Client.new
  Chef::Log.debug("************ after client object ************* ")
  # finding the master node
=begin
  master_node = ""
  if node[:opsworks][:instance][:layers] && node[:opsworks][:layers][:application] && !node[:opsworks][:layers][:application][:instances].blank?
    master_node = node[:opsworks][:layers][:application][:instances].keys.sort.first
  end
  if master_node
    # master_node id for triggering the deployment
    if !master_node.blank?
      master_node_id = node[:opsworks][:layers][:application][:instances][master_node][:id]
      # describing the current deployment for finding all the instances on which deployment is triggered
      instance_ids = []
    end
=end
Chef::Log.debug "opsworks #{opsworks}"
Chef::Log.debug "node[:opsworks] #{node[:opsworks].inspect}"
instance_ids = []
    # checking if this is deployment or new instance
    if node[:opsworks][:deployment]
      deployment = opsworks.describe_deployments(:deployment_ids => [node[:opsworks][:deployment]])
      # getting the deployment details
      deployment_details = deployment[:deployments].first
      # getting the stack_id
      stack_id = deployment_details[:stack_id]
      # getting all the instances where nginx restart should be triggered
      instance_ids = deployment_details[:instance_ids]
    else
      stack_id = node[:opsworks]["stack"]["id"]
      instance_ids = [node[:opsworks]["instance"]["id"]]      
    end
    Chef::Log.debug "instance_ids #{instance_ids}"
    Chef::Log.debug "stack_id #{stack_id}"
    # check if instance_id include master_node because the deployment would be triggered from
    # master node else restart nginx that means a partial deployment
    opsworks.create_deployment({
                                 :stack_id =>  stack_id,
                                 :instance_ids => instance_ids,
                                 :command => {
                                   :name =>  "execute_recipes",
                                   :args => {
                                     "recipes" => ["deploy::activities_restart"]
                                   }
                                 },
                                 :comment => "service restart from master"

    })
    Chef::Log.debug("************ after deploy ************* ")
    #newrelic_key = (node["opsworks"]["environment"] == "production") ? "53e0eade912ffb2c559d6f3c045fe363609df3ee" : "7a4f2f3abfd0f8044580034278816352324a9fb7"
    #long_user_string = node["deploy"][node["opsworks"]["applications"][0]["slug_name"]]["deploying_user"]
    #something like: "arn:aws:iam::(long-number):user/username"
    #username = long_user_string.split('/').last
    #Chef::Log.debug "curl -H \"x-license-key:#{newrelic_key}\" -d \"deployment[app_name]=#{node['opsworks']['stack']['name']} / activities (#{node['opsworks']['environment']})\" -d \"deployment[user]=#{username}\" https://rpm.newrelic.com/deployments.xml"
    begin
      #run "curl -H \"x-license-key:#{newrelic_key}\" -d \"deployment[app_name]=#{node['opsworks']['stack']['name']} / activities (#{node['opsworks']['environment']})\" -d \"deployment[user]=#{username}\" https://rpm.newrelic.com/deployments.xml"
    rescue  Exception => e  
      Chef::Log.debug "The following error occurred: #{e.message}"
    end
#  end
  Chef::Log.debug("************ after after restart ************* ")
end