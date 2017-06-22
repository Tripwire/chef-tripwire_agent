# # encoding: utf-8

# Inspec test for recipe tripwire_agent::java_agent

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

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

if os.windows?
  # Windows --removeall option leaves agent/bin directories
  describe directory(agent_dir + '/data') do
    it { should_not exist }
  end
else
  describe directory(agent_dir) do
    it { should_not exist }
  end
end

# Agent service installed and running
describe service(srvc_nme) do
  it { should_not be_installed }
  it { should_not be_enabled }
  it { should_not be_running }
end

# EG service should be installed and running
describe service(eg_srvc_nme) do
  it { should_not be_installed }
  it { should_not be_enabled }
  it { should_not be_running }
end

# EG Port should be listening locally
describe port(1169) do
  it { should_not be_listening }
  its('processes') { should_not include eg_process_nme }
  its('protocols') { should_not include 'tcp' }
  its('addresses') { should_not include '127.0.0.1' }
end

# Verfiy Agent properties file is set correctly
describe file(properties_file) do
  it { should_not exist }
end

# Verify that the tags.properties file was generated and contains the correct tags
describe file(tag_file) do
  it { should_not exist }
end
