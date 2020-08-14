property :installer, [String, nil], name_property: true
property :eg_driver_installer, [String, nil], default: nil
property :eg_service_installer, [String, nil], default: nil
property :eg_install, [true, false], default: true
property :dns_srvc_name, String, default: '_tw_gw'
property :dns_srvc_domain, [String, nil], default: nil
property :bridge_auth_mode, [String, nil], default: 'registration'
property :keystore_password, [String, nil], default: nil
property :registration_filename, String, default: 'registration_pre_shared_key.txt'
property :registration_key, [String, nil], default: nil
property :proxy_hostname, [String, nil], default: nil
property :proxy_port, Integer, default: 1080
property :proxy_username, [String, nil], default: nil
property :proxy_password, [String, nil], default: nil
property :tls_version, [String, nil], default: nil
property :cipher_suites, [String, nil], default: nil
property :spool_size, String, default: '1g'
property :bridge, [String, nil], default: nil
property :bridge_port, Integer, default: 5670
property :start_service, [true, false], default: true
property :clean, [true, false], default: true
property :tags, Hash, default: {}
property :use_dkms_driver, [true, false], default: false
if node['platform'] == 'windows'
  property :install_directory, String, default: 'C:\Program Files\Tripwire\Agent'
  property :config_directory, String, default: 'C:\ProgramData\Tripwire\Agent\config'
  property :service_name, String, default: 'TripwireAxonAgent'
else
  property :install_directory, String, default: '/opt/tripwire/agent'
  property :config_directory, String, default: '/etc/tripwire'
  property :service_name, String, default: 'tripwire-axon-agent'
end

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
  when 'centos', 'redhat', 'suse', 'oraclelinux', 'oracle', 'amazon'
    ext = '.rpm'
    eg_service_name = 'tw-eg-service'
  when 'debian', 'ubuntu'
    ext = '.deb'
    eg_service_name = 'tw-eg-service'
  when 'windows'
    ext = '.msi'
    eg_service_name = 'TripwireEventGeneratorService'
  else
    raise 'Unknown platform detected, Aborting run.'
  end

  service_name = new_resource.service_name
  config_path = new_resource.config_directory

  # Create configuration directory
  directory config_path do
    recursive true
    action :create
  end

  # Create configuration from template
  template config_path + '/twagent.conf' do
    source 'twagent.erb'
    variables(template_hash)
    cookbook 'tripwire_agent'
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

  agent_source_is_url = new_resource.installer.start_with?('http')
  agent_source_is_tgz = new_resource.installer.end_with?('tgz')
  agent_source_is_zip = new_resource.installer.end_with?('zip')

  # Set the correct header for the agent installer
  agent_source = agent_source_is_url ? new_resource.installer : 'file:///' + new_resource.installer
  folder = ::File.basename(agent_source, '.*')
  axon_chef_cache = "#{::Chef::Config['file_cache_path']}/#{folder}"

  # Set local cache target for the installers
  node.run_state['local_installer'] = "#{::Chef::Config['file_cache_path']}/te_axon#{ext}"

  # Download and unzip the installer
  if agent_source_is_tgz
    tar_extract agent_source do
      target_dir ::Chef::Config['file_cache_path']
      action :extract
      # Use the license file for idempotency
      creates "#{axon_chef_cache}/license.html"
    end
  elsif agent_source_is_zip
    windows_zipfile 'windows_zip' do
      source agent_source
      path ::Chef::Config['file_cache_path']
      action :unzip
    end
  else
    remote_file node.run_state['local_installer'] do
      source agent_source
      mode '744' unless node['platform'] == 'windows'
    end
  end

  # Automatically set the sources from the compressed file
  if agent_source_is_tgz || agent_source_is_zip
    ruby_block 'get files' do
      block do
        files = ::Dir.entries(axon_chef_cache)
        file_string = agent_source_is_tgz ? 'agent-installer' : 'Axon_Agent'
        installer_basename = files.find { |item| item.include?(file_string) }

        # Set the local installer location
        node.run_state['local_installer'] = "#{axon_chef_cache}/#{installer_basename}"

        log lazy { node.run_state['local_installer'] }

        # Only necessary to set these if a linux box
        if new_resource.eg_install && !platform_family?('windows')
          service_basename = files.find { |item| item.include?('service') }
          if new_resource.use_dkms_driver
            driver_basename = files.find { |item| item.include?('driver-dkms')}
          else
            # There can be multiple eg-driver files e.g driver-dkms, driver-rhel, driver-suse
            driver_basename_list = files.select { |item| item.include?('driver') and !item.include?('driver-dkms')}
            if !platform_family?('suse')
              driver_basename = driver_basename_list.find {|item| !item.include?('suse') }
            else
              driver_basename = driver_basename_list.find {|item| item.include?('suse') }
            end
          end

          # Determine the local driver and service locations
          local_eg_service = "#{axon_chef_cache}/#{service_basename}"
          local_eg_driver = "#{axon_chef_cache}/#{driver_basename}"
          node.run_state['local_eg_service'] = local_eg_service
          node.run_state['local_eg_driver'] = local_eg_driver
        end
      end
      action :run
    end
  elsif new_resource.eg_install && (!new_resource.eg_service_installer.nil? || !new_resource.eg_driver_installer.nil?)
    # In case we have not set the driver and service, we can assume they
    # were manually specified and need to download them to the node.
    node.run_state['local_eg_driver'] = ::Chef::Config['file_cache_path'] + '/eg_driver' + ext
    node.run_state['local_eg_service'] = ::Chef::Config['file_cache_path'] + '/eg_service' + ext

    # Set the correct header for the eg driver installer
    eg_driver_source = new_resource.eg_driver_installer.start_with?('http') && new_resource.eg_install ? new_resource.eg_driver_installer : 'file:///' + new_resource.eg_driver_installer

    # Set the corret header for the eg service installer
    eg_service_source = new_resource.eg_service_installer.start_with?('http') && new_resource.eg_install ? new_resource.eg_service_installer : 'file:///' + new_resource.eg_service_installer

    # Install package eg if enabled & not windows
    remote_file lazy { node.run_state['local_eg_driver'] } do
      source eg_driver_source
      mode '0744'
    end
    remote_file lazy { node.run_state['local_eg_service'] } do
      source eg_service_source
      mode '0744'
    end
  end

  # If the service installer or the driver installer are not specified, we will not install unless
  # the agent source is a tgz file. In this case the installers do not need to be set since they were derived
  # in the tgz.
  eg_specified = (!new_resource.eg_driver_installer.nil? && !new_resource.eg_service_installer.nil?) || agent_source_is_tgz
  install_eg_components = !platform?('windows') && eg_specified && new_resource.eg_install

  if install_eg_components
    # Install EG driver
    %w(local_eg_driver local_eg_service).each do |name|
      if platform_family?('debian')
        dpkg_package 'pkg' do
          package_name lazy { node.run_state[name] }
          action :install
        end
      elsif platform_family?('rhel')
        rpm_package 'pkg' do
          package_name lazy { node.run_state[name] }
          action :install
        end
      else
        # All other platforms we use generic packages
        package 'pkg' do
          package_name lazy { node.run_state[name] }
          action :install
        end
      end
    end
  end

  log lazy { node.run_state['local_installer'] }

  # Install the actual agent
  if platform_family?('debian')
    dpkg_package lazy { node.run_state['local_installer'] } do
      action :install
    end
  elsif platform_family?('rhel')
    rpm_package lazy { node.run_state['local_installer'] } do
      action :install
    end
  else
    package 'axon installer' do
      source lazy { node.run_state['local_installer'] }
      action :install
    end
  end

  # Start Axon agent service
  # Windows Axon agents start the service automatically
  service eg_service_name do
    action :start
    only_if { new_resource.start_service && node['platform'] != 'windows' && new_resource.eg_install && (!new_resource.eg_driver_installer.nil? && !new_resource.eg_service_installer.nil?) }
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
  when 'centos', 'redhat', 'oraclelinux', 'amazon'
    agent_package = 'axon-agent'
    eg_driver_package = node['packages'].include?('tw-eg-driver-dkms') ? 'tw-eg-driver-dkms' : 'tw-eg-driver-rhel'
    eg_service_package = 'tw-eg-service'
    config_path = '/etc/tripwire'
  when 'debian', 'ubuntu'
    agent_package = 'axon-agent'
    eg_driver_package = node['packages'].include?('tw-eg-driver-dkms') ? 'tw-eg-driver-dkms' : 'tw-eg-driver-debian'
    eg_service_package = 'tw-eg-service'
    config_path = '/etc/tripwire'
  when 'suse'
    agent_package = 'axon-agent'
    eg_driver_package = 'tw-eg-driver-suse'
    eg_service_package = 'tw-eg-service'
    config_path = '/etc/tripwire'
  when 'windows'
    agent_package = 'Axon Agent'
    config_path = 'C:\ProgramData\Tripwire\Agent\config'
  else
    raise 'Unknown platform detected, Aborting run.'
  end

  # Remove EG service and Driver on non-Windows platforms
  unless platform?('windows')
    [eg_service_package, eg_driver_package].each do |pkg|
      if platform_family?('debian')
        dpkg_package pkg do
          action :remove
        end
      elsif platform_family?('rhel')
        rpm_package pkg do
          action :remove
        end
      else
        package pkg do
          action :remove
        end
      end
    end
  end

  # Remove Agent
  if platform_family?('debian')
    dpkg_package agent_package do
      action :remove
    end
  elsif platform_family?('rhel')
    rpm_package agent_package do
      action :remove
    end
  else
    package agent_package do
      action :remove
    end
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
