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
  its('content') { should match /dns\.service\.name=bridge/ }
  its('content') { should match /dns\.service\.domain=example\.com/ }
  its('content') { should match /socks5\.host=tw-proxy\.example\.com/ }
  its('content') { should match /socks5\.port=1180/ }
  its('content') { should match /socks5\.user\.name=twsocks01/ }
  its('content') { should match /socks5\.user\.password=T357pAs5W0rD!/ }
  its('content') { should match /spool\.size\.max=3g/ }
  its('content') { should match /tls\.version=TLSv1\.1/ }
  its('content') { should match /tls\.cipher\.suites=AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384/ }
end

# Tag file for the Axon agent should exist with properly content
describe file(tag_file) do
  it { should_not exist }
end

# Axon agents registration key should exist and contain the test password
describe file(reg_key_file) do
  it { should_not exist }
end

# Axon agent should be installed
describe package(pkg_name) do
  it { should be_installed }
end

if os.windows?
  # Windows includes the EG driver and service, no flags exist
  # currently to prevent it's installation

  # Axon service should be installed and running
  describe service(srvc_nme) do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  # Axon EG service should be installed and running
  describe service(eg_srvc_nme) do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
  # EG port should be listening locally
  describe port(1169) do
    it { should be_listening }
    its('processes') { should include eg_process_nme }
    its('protocols') { should include 'tcp' }
    its('addresses') { should include '127.0.0.1' }
  end

else
  # Axon service should be installed but not be running
  describe service(srvc_nme) do
    it { should be_installed }
    it { should be_enabled }
    it { should_not be_running }
  end

  # Axon EG service should not be installed
  describe service(eg_srvc_nme) do
    it { should_not be_installed }
  end

  # EG Port should not be listening locally
  describe port(1169) do
    it { should_not be_listening }
  end
end
