# # encoding: utf-8

# Inspec test for recipe tripwire_agent::axon_agent

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

if os.windows?
  config_dir = 'C:\ProgramData\Tripwire\agent\config'
  config_file = config_dir + '\twagent.conf'
  reg_key_file = config_dir + '\registration_pre_shared_key.txt'
  pkg_name = 'tw-axon-agent-ip360'
  srvc_nme = 'Tripwire Axon Agent for IP360'
else
  config_dir = '/etc/tripwire-ip360'
  config_file = config_dir + '/twagent.conf'
  reg_key_file = config_dir + '/registration_pre_shared_key.txt'
  pkg_name = 'tw-axon-agent-ip360'
  srvc_nme = 'tw-axon-agent-ip360'
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

  # Following should not exist in the file
  its('content') { should_not match /dns\.service\.name=bridge/ }
  its('content') { should_not match /dns\.service\.domain=example\.com/ }
  its('content') { should_not match /socks5\.*/ }
  its('content') { should_not match /tls\.version*/ }
  its('content') { should_not match /tls\.cipher\.suites*/ }
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
