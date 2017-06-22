default['tripwire_agent']['installer'] = nil
default['tripwire_agent']['tags'] = {}
default['tripwire_agent']['proxy_hostname'] = nil
default['tripwire_agent']['proxy_port'] = 1080
default['tripwire_agent']['install_rtm'] = true
default['tripwire_agent']['rtm_port'] = 1169
default['tripwire_agent']['start_service'] = true

# Java specfic
default['tripwire_agent']['java']['console']
default['tripwire_agent']['java']['services_password'] = nil
default['tripwire_agent']['java']['console_port'] = 9898
default['tripwire_agent']['java']['proxy_agent'] = false
default['tripwire_agent']['java']['fips'] = false
default['tripwire_agent']['java']['integration_port'] = 8080
default['tripwire_agent']['java']['install_directory'] =
  if node['platform'] == 'windows'
    'C:\Program Files\Tripwire\TE\Agent'
  else
    '/usr/local/tripwire/te/agent'
  end
default['tripwire_agent']['java']['removeall'] = true

# Axon specific
default['tripwire_agent']['axon']['eg_driver_installer'] = nil
default['tripwire_agent']['axon']['eg_service_installer'] = nil
default['tripwire_agent']['axon']['eg_install'] = true
default['tripwire_agent']['axon']['bridge'] = nil
default['tripwire_agent']['axon']['bridge_port'] = 5670
default['tripwire_agent']['axon']['dns_srvc_name'] = '_tw_gw'
default['tripwire_agent']['axon']['dns_srvc_domain'] = nil
default['tripwire_agent']['axon']['bridge_auth_mode'] = 'registration'
default['tripwire_agent']['axon']['keystore_password'] = nil
default['tripwire_agent']['axon']['registration_filename'] = 'registration_pre_shared_key.txt'
default['tripwire_agent']['axon']['registration_key'] = nil
default['tripwire_agent']['axon']['proxy_username'] = nil
default['tripwire_agent']['axon']['proxy_password'] = nil
default['tripwire_agent']['axon']['tls_version'] = nil
default['tripwire_agent']['axon']['cipher_suites'] = nil
default['tripwire_agent']['axon']['spool_size'] = '1g'
default['tripwire_agent']['axon']['clean'] = true
