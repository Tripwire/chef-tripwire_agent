#
# Cookbook:: tripwire_agent
# Recipe:: java_agent
#

tripwire_agent_java 'Install Tripwire Enterprise Java Agent' do
  installer node['tripwire_agent']['installer']
  console node['tripwire_agent']['java']['console']
  services_password node['tripwire_agent']['java']['services_password']
  console_port node['tripwire_agent']['java']['console_port']
  install_directory node['tripwire_agent']['java']['install_directory']
  install_rtm node['tripwire_agent']['install_rtm']
  rtm_port node['tripwire_agent']['rtm_port']
  proxy_agent node['tripwire_agent']['java']['proxy_agent']
  proxy_hostname node['tripwire_agent']['proxy_hostname']
  proxy_port node['tripwire_agent']['proxy_port']
  fips node['tripwire_agent']['java']['fips']
  integration_port node['tripwire_agent']['java']['integration_port']
  start_service node['tripwire_agent']['start_service']
  tags node['tripwire_agent']['tags']
end

# Might be better to leave starting the service out of the custom resource
# Customers might want to manage service control their own way instead of
# letting the provider do it for them.
