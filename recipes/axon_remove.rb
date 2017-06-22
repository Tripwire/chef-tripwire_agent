#
# Cookbook:: tripwire_agent
# Recipe:: axon_remove
#

tripwire_agent_axon 'Removing Axon agent' do
  action :remove
  clean node['tripwire_agent']['axon']['clean']
end
