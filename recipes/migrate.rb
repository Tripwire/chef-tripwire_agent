#
# Cookbook:: tripwire_agent
# Recipe:: migrate
#

log 'Migrating system from Tripwire Java agents to Axon' do
  level :warn
end

include_recipe 'tripwire_agent::java_remove'

include_recipe 'tripwire_agent::axon_agent'
