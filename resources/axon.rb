property :installer,              [String, nil], name_property: true
property :eg_driver_installer,    [String, nil], default: nil
property :eg_service_installer,   [String, nil], default: nil
property :install_directory,      [String, nil], default: nil
property :eg_install,             [true, false], default: true
property :dns_srvc_name,          String, default: '_tw_gw'
property :dns_srvc_domain,        [String, nil], default: nil
property :bridge_auth_mode,       [String, nil], default: 'registration'
property :keystore_password,      [String, nil], default: nil
property :registration_filename,  String, default: 'registration_pre_shared_key.txt'
property :registration_key,       [String, nil], default: nil
property :proxy_hostname,         [String, nil], default: nil
property :proxy_port,             Integer, default: 1080
property :proxy_username,         [String, nil], default: nil
property :proxy_password,         [String, nil], default: nil
property :tls_version,            [String, nil], default: nil
property :cipher_suites,          [String, nil], default: nil
property :spool_size,             String, default: '1g'
property :bridge,                 [String, nil], default: nil
property :bridge_port,            Integer, default: 5670
property :start_service,          [true, false], default: true
property :clean,                  [true, false], default: true
property :tags,                   Hash, default: {}

default_action :install

action :install do
  require 'json'
  ::Chef::Recipe.send(:include, Windows::Helper)

  template_hash = {
    'dns_srvc_name' => new_resource.dns_srvc_name,
    'dns_srvc_domain' => new_resource.dns_srvc_domain,
    'bridge' => new_resource.bridge,
    'bridge_port' => new_resource.bridge_port,
    'keystore_password' => new_resource.keystore_password,
    'registration_key' => new_resource.registration_key,
    'registration_filename' => new_resource.registration_filename,
    'proxy_hostname' => new_resource.proxy_hostname,
    'proxy_port' => new_resource.proxy_port,
    'proxy_username' => new_resource.proxy_username,
    'proxy_password' => new_resource.proxy_password,
    'tls_version' => new_resource.tls_version,
    'cipher_suites' => new_resource.cipher_suites,
    'spool_size' => new_resource.spool_size,
  }

  tag_template = JSON.parse({ 'tagSets' => new_resource.tags }.to_hash.dup.to_json).to_yaml

  # Set platform specific variables
  case node['platform']
  when  'centos', 'redhat', 'suse', 'oraclelinux'
    ext = '.rpm'
    service_name = 'tripwire-axon-agent'
    eg_service_name = 'tw-eg-service'
    config_path = '/etc/tripwire'
  when 'debian', 'ubuntu'
    ext = '.deb'
    service_name = 'tripwire-axon-agent'
    eg_service_name = 'tw-eg-service'
    config_path = '/etc/tripwire'
  when 'windows'
    ext = '.msi'
    service_name = 'TripwireAxonAgent'
    eg_service_name = 'TripwireEventGeneratorService'
    config_path = 'C:\ProgramData\Tripwire\Agent\config'
  else
    raise 'Unknown platform detected, Aborting run.'
  end

  # Create configuration directory
  directory config_path do
    recursive true
    action :create
  end

  # Create configuration from template
  template config_path + '/twagent.conf' do
    source 'twagent.erb'
    variables(template_hash)
  end

  # Create registry key file if enabled
  file config_path + '/' + new_resource.registration_filename do
    content new_resource.registration_key
    not_if { new_resource.registration_key.nil? }
  end

  # Create tagging file if tags are present
  file config_path + '/metadata.yml' do
    content tag_template
    not_if { new_resource.tags.empty? }
  end

  # Set local cache target for the installers
  local_installer = ::Chef::Config['file_cache_path'] + '/te_agent' + ext

  # Set the correct header for the agent installer
  agent_source = if new_resource.installer.start_with?('http')
                   new_resource.installer
                 else
                   'file:///' + new_resource.installer
                 end

  # Download installer
  remote_file local_installer do
    source agent_source
    mode '744' unless node['platform'] == 'windows'
  end

  if node['platform'] != 'windows' && (new_resource.eg_driver_installer != nil || new_resource.eg_service_installer != nil)

    # Set local cache target for the driver and service
    local_eg_driver = ::Chef::Config['file_cache_path'] + '/eg_driver' + ext
    local_eg_service = ::Chef::Config['file_cache_path'] + '/eg_service' + ext

    # Set the correct header for the eg driver installer
    eg_driver_source = if eg_driver_installer.start_with?('http') && eg_install
                         new_resource.eg_driver_installer
                       else
                         'file:///' + new_resource.eg_driver_installer
                       end

    # Set the corret header for the eg service installer
    eg_service_source = if eg_service_installer.start_with?('http') && new_resource.eg_install
                          new_resource.eg_service_installer
                        else
                          'file:///' + new_resource.eg_service_installer
                        end

    # Install package eg if enabled & not windows
    remote_file local_eg_driver do
      source eg_driver_source
      mode '0744'
    end
    remote_file local_eg_service do
      source eg_service_source
      mode '0744'
    end

    # Install EG driver and service
    package local_eg_driver do
      provider Chef::Provider::Package::Dpkg if node['platform_family'] == 'debian'
    end

    package local_eg_service do
      provider Chef::Provider::Package::Dpkg if node['platform_family'] == 'debian'
    end

  end

  # Install Axon agent
  package local_installer do
    provider Chef::Provider::Package::Dpkg if node['platform_family'] == 'debian'
  end

  # Start Axon agent service
  # Windows Axon agents start the service automatically
  service eg_service_name do
    action :start
    only_if { new_resource.start_service && node['platform'] != 'windows' && (new_resource.eg_driver_installer != nil || new_resource.eg_service_installer != nil) }
  end
  service service_name do
    action :start
    only_if { new_resource.start_service && node['platform'] != 'windows' }
  end
end

action :remove do
  # Removes an axon agent
  # Set platform specific variables
  case node['platform']
  when 'centos', 'redhat', 'oraclelinux'
    agent_package = 'axon-agent'
    if node['packages'].include?('tw-eg-driver-dkms')
      eg_driver_package = 'tw-eg-driver-dkms'
    else
      eg_driver_package = 'tw-eg-driver-rhel'
    end
    eg_service_package = 'tw-eg-service'
    config_path = '/etc/tripwire'
  when 'debian', 'ubuntu'
    agent_package = 'axon-agent'
    if node['packages'].include?('tw-eg-driver-dkms')
      eg_driver_package = 'tw-eg-driver-dkms'
    else
      eg_driver_package = 'tw-eg-driver-debian'
    end
    eg_service_package = 'tw-eg-service'
    config_path = '/etc/tripwire'
  when 'suse'
    agent_package = 'axon-agent'
    if node['packages'].include?('tw-eg-driver-dkms')
      eg_driver_package = 'tw-eg-driver-dkms'
    else
      eg_driver_package = 'tw-eg-driver-suse'
    end
    eg_service_package = 'tw-eg-service'
    config_path = '/etc/tripwire'
  when 'windows'
    agent_package = 'Axon Agent'
    config_path = 'C:\ProgramData\Tripwire\Agent\config'
  else
    raise 'Unknown platform detected, Aborting run.'
  end

  # Remove EG service on non-Windows platforms
  package 'Removing linux EG service' do
    package_name eg_service_package
    action :remove
    provider Chef::Provider::Package::Dpkg if node['platform_family'] == 'debian'
    not_if { node['platform'] == 'windows' }
  end
  # Remove EG driver on non-Windows platforms
  package 'Removing linux EG driver' do
    package_name eg_driver_package
    action :remove
    provider Chef::Provider::Package::Dpkg if node['platform_family'] == 'debian'
    not_if { node['platform'] == 'windows' }
  end
  # Remove Agent
  package agent_package do
    action :remove
    provider Chef::Provider::Package::Dpkg if node['platform_family'] == 'debian'
  end
  # Reset systemctl
  execute 'systemctl daemon-reload' do
    only_if { platform_family?('rhel') && node['platform_version'].to_f >= 7.0 || platform_family?('debian') }
  end
  # Cleanup leftovers
  directory config_path do
    action :delete
    recursive true
    only_if { new_resource.clean }
  end
end

action :upgrade do
  # Upgrades an axon agent to a more current version
  # TO-DO: this
end
