# # encoding: utf-8

# Inspec test for recipe tripwire_agent::axon_agent

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

if os.windows?
  config_dir = 'C:\ProgramData\Tripwire\agent\config'
  agent_package = 'Axon Agent'
  agent_service_name = 'TripwireAxonAgent'
  eg_service_package = 'TripwireEventGeneratorService'
  eg_process_name = 'tesvc.exe'
else
  config_dir = '/etc/tripwire'
  agent_package = 'axon-agent'
  agent_service_name = 'tripwire-axon-agent'
  eg_service_package = 'tw-eg-service'
  eg_driver_package = 'tw-eg-driver'
  eg_process_name = 'tesvc'
end

# Axon config directory should exist
describe directory(config_dir) do
  it { should_not exist }
end

# Axon agent should be installed
describe package(agent_package) do
  it { should_not be_installed }
end

unless os.windows?
  # Axon EG driver has been removed from linux
  describe package(eg_driver_package) do
    it { should_not be_installed }
  end
end

describe package(eg_service_package) do
  it { should_not be_installed }
end

# Axon service is not installed or running
describe service(agent_service_name) do
  it { should_not be_installed }
  it { should_not be_enabled }
  it { should_not be_running }
end

# Axon EG service not installed or running
describe service(eg_service_package) do
  it { should_not be_installed }
  it { should_not be_enabled }
  it { should_not be_running }
end

# EG Port should be listening locally
describe port(1169) do
  it { should_not be_listening }
  its('processes') { should_not include eg_process_name }
  its('protocols') { should_not include 'tcp' }
  its('addresses') { should_not include '127.0.0.1' }
end
