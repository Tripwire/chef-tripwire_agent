# # encoding: utf-8

# Inspec test for recipe tripwire_agent::axon_agent

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

if os.windows?
  config_dir = 'C:\ProgramData\Tripwire\agent\config'
  config_file = config_dir + '\twagent.conf'
  tag_file = config_dir + '\metadata.yml'
  reg_key_file = config_dir + '\registration_pre_shared_key.txt'
  pkg_name = 'Axon Agent'
  srvc_nme = 'TripwireAxonAgent'
  eg_srvc_nme = 'TripwireEventGeneratorService'
  eg_process_nme = 'tesvc.exe'
else
  config_dir = '/etc/tripwire'
  config_file = config_dir + '/twagent.conf'
  tag_file = config_dir + '/metadata.yml'
  reg_key_file = config_dir + '/registration_pre_shared_key.txt'
  pkg_name = 'axon-agent'
  srvc_nme = 'tripwire-axon-agent'
  eg_srvc_nme = 'tw-eg-service'
  eg_process_nme = 'tesvc'
end

# Axon config directory should exist
describe directory(config_dir) do
  it { should exist }
end

# Configuration file should exist and have the bridge, port, and spool size set
describe file(config_file) do
  it { should exist }
  its('content') { should match /bridge\.host=tw-bridge\.example.com/ }
  its('content') { should match /bridge\.port=5670/ }
  its('content') { should match /spool.size.max=1g/ }
end

# Tag file for the Axon agent should exist with properly content
describe file(tag_file) do
  it { should exist }
end

describe yaml(tag_file) do
  its(['tagSets', 'tagset1']) { should eq 'tag1a'}
  its(['tagSets', 'tagset2']) { should eq ['tag2a', 'tag2b']}
  its(['tagSets', 'tagset3']) { should eq ['tag3a', 'tag3b', 'tag3c']}
end

# Axon agents registration key should exist and contain the test password
describe file(reg_key_file) do
  it { should exist }
  its('content') { should match /123PAs5W0rD/ }
end

# Axon agent should be installed
describe package(pkg_name) do
  it { should be_installed }
end

# Axon service should be running
describe service(srvc_nme) do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

# Axon EG service installed and be running
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
