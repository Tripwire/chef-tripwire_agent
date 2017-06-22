#
# Cookbook:: tripwire_agent
# Recipe:: java_remove
#

tripwire_agent_java 'Remove Tripwire Enterprise Java agent' do
  action :remove
  install_directory node['tripwire_agent']['java']['install_directory']
  removeall node['tripwire_agent']['java']['removeall']
end
