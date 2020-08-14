#
# Cookbook:: tripwire_agent
# Recipe:: axon_agent
#

tripwire_agent_axon 'Install Tripwire Axon agent' do
  installer node['tripwire_agent']['installer']
  eg_install node['tripwire_agent']['axon']['eg_install']
  use_dkms_driver node['tripwire_agent']['axon']['use_dkms_driver']
  eg_driver_installer node['tripwire_agent']['axon']['eg_driver_installer']
  eg_service_installer node['tripwire_agent']['axon']['eg_service_installer']
  install_directory node['tripwire_agent']['axon']['install_directory']
  config_directory node['tripwire_agent']['axon']['config_directory']
  service_name node['tripwire_agent']['axon']['service_name']
  dns_srvc_name node['tripwire_agent']['axon']['dns_srvc_name']
  dns_srvc_domain node['tripwire_agent']['axon']['dns_srvc_domain']
  bridge_auth_mode node['tripwire_agent']['axon']['bridge_auth_mode']
  keystore_password node['tripwire_agent']['axon']['keystore_password']
  registration_filename node['tripwire_agent']['axon']['registration_filename']
  registration_key node['tripwire_agent']['axon']['registration_key']
  proxy_hostname node['tripwire_agent']['proxy_hostname']
  proxy_port node['tripwire_agent']['proxy_port']
  proxy_username node['tripwire_agent']['axon']['proxy_username']
  proxy_password node['tripwire_agent']['axon']['proxy_password']
  tls_version node['tripwire_agent']['axon']['tls_version']
  cipher_suites node['tripwire_agent']['axon']['cipher_suites']
  spool_size node['tripwire_agent']['axon']['spool_size']
  bridge node['tripwire_agent']['axon']['bridge']
  bridge_port node['tripwire_agent']['axon']['bridge_port']
  start_service node['tripwire_agent']['start_service']
  tags node['tripwire_agent']['tags']
end
