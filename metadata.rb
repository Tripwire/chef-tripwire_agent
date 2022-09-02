name 'tripwire_agent'
maintainer 'Tripwire Inc.'
maintainer_email 'TW-OCTO@tripwire.com'
license 'Apache-2.0'
description 'Installs/Configures tripwire_agent'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.1.6'
chef_version '>= 13' if respond_to?(:chef_version)

source_url 'https://github.com/Tripwire/chef-tripwire_agent'
issues_url 'https://github.com/Tripwire/chef-tripwire_agent/issues'

depends 'windows', '~> 3.0'
depends 'tar', '~> 2.2'
supports 'redhat'
supports 'centos'
supports 'windows'
supports 'ubuntu'
supports 'debian'
supports 'suse'
supports 'amazon'
