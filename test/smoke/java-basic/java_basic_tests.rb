# # encoding: utf-8

# Inspec test for recipe tripwire_agent::java_agent

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

require 'spec_helper'

if os.windows?
  agent_dir = 'C:\Program Files\Tripwire\TE\agent'
  srvc_nme = 'teagent'
  eg_srvc_nme = 'tesvc'
  eg_process_nme = 'tesvc.exe'
else
  agent_dir = '/usr/local/tripwire/te/agent'
  srvc_nme = 'twdaemon'
  eg_srvc_nme = 'twrtmd'
  eg_process_nme = 'tesvc'
end

# Non-platform specific variables
properties_file = agent_dir + '/data/config/agent.properties'
tag_file = agent_dir + '/data/config/agent.tags.conf'

# Agent service installed and running
describe service(srvc_nme) do
  it { should be_installed }
  it { should be_enabled } if host_inventory['platform'] == 'redhat' && host_inventory['platform_version'].to_f >= 7.0
  it { should be_running }
end

# EG service should be installed and running
describe service(eg_srvc_nme) do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running } if host_inventory['platform'] == 'redhat' && host_inventory['platform_version'].to_f >= 7.0
end

# EG Port should be listening locally
describe port(1169) do
  it { should be_listening }
  its('processes') { should include eg_process_nme }
  its('protocols') { should include 'tcp' }
  its('addresses') { should include '127.0.0.1' }
end

# Verfiy Agent properties file is set correctly
describe file(properties_file) do
  its(:content) { should match /tw\.server\.port=9898/ }
  its(:content) { should match /tw\.server\.host=testconsole\.example\.com/ }
  its(:content) { should match /tw\.agent\.generator\.port=1169/ }
end

# Verify that the tags.properties file was generated and contains the correct tags
describe file(tag_file) do
  it { should exist }
  its(:content) { should match /tag_set1:1_tag1/ }
  its(:content) { should match /tag_set1:1_tag2/ }
  its(:content) { should match /tag_set2:2_tag1/ }
end
