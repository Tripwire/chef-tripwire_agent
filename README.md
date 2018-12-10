# tripwire_agent

Cookbook installs Tripwire Enterprise Agents, either Axon or Java. This cookbook also provides a resource to upgrade a Java agent

## Features

This cookbook provides resources for the installation of Tripwire Enterprise Axon and Java agents. Users are able to include this cookbook in their own cookbooks or use the cookbook on its own to install their agents within their infrastructure. A recipe is also included to migrate a system from a Java agent to an Axon agent.

## Requirements

* Chef 13 or higher
* Tripwire Enterprise installers available through a share or web service

## Provider Documentation

### Axon Parameters

| Parameter | Definition | Type |
|-----------|------------|------|
| `installer` | Defines the path to the installer package or compressed tar/zip file for the axon agent, accepts urls to the installer | String |
| `eg_install` | If set to true, installs the event generator drivers and service (linux/debian only) | Boolean |
| `use_dkms_driver` | If set to true, uses the DKMS specific driver packaged in the compressed tar file (linux/debian only) | Boolean |
| `eg_driver_installer` | Defines the path to the installer package for the axon EG driver installer (linux/debian only), only required if not using a compressed tar file | String |
| `eg_service_installer` | Defines the path to the installer package for the axon EG service installer (linux/debian only), only required if not using a compressed tar file | String |
| `install_directory` | Install path for the Axon agent (current not in use) | String |
| `config_directory` | Configuration directory, for IP360 and TLC Axon agents | String |
| `service_name` | Service name for the IP360 and TLC Axon Agents | String |
| `dns_srvc_name` | Sets the DNS pointer for the Bridge service | String |
| `dns_srvc_domain` | Sets the DNS domain for the pointer | String |
| `bridge_auth_mode` | Registration type, password or PKI | String |
| `keystore_password` | PKI keystore password | String |
| `registration_filename` | Registration password file | String |
| `registration_key` | Registration password for the Bridge | String |
| `proxy_hostname` | Proxy hostname used by the Axon agent | String |
| `proxy_port` | Proxy port used by the Axon agent | Integer |
| `proxy_username` | Proxy username used by the Axon agent | String |
| `proxy_password` | Proxy password used by the Axon agent | String |
| `tls_version` | TLS version used by the agent, TLSv1.0, TLSv1.1, TLSv1.2 | String |
| `cipher_suites` | Cipher suites used by Axon to connect to the Bridge | String |
| `spool_size` | Spool size used by the agent, default 1g | String |
| `bridge` | Bridge hostname or IP if not using DNS to connect to the Bridge | String |
| `bridge_port` | 'Bridge port, used to connect if the Bridge is set' | Integer |
| `start_service` | Start the agent service post install (See Gotchas) | Boolean |
| `tags` | Key/Value hash of tags used when registering to Tripwire Enterprise | Hash |
| `clean` | Used for the remove action, deletes the configuration directory | true |

### Axon Actions

* `:install` - Default action, Installs the Axon agent
* `:remove` - Removes an existing Axon agent

### Java Parameters

| Parameter | Definition | Type |
|-----------|------------|------|
| `installer` | Defines the path to the Java agent installer binary or compressed tar file | String |
| `console` | Defines the Tripwire Enterprise console server | String |
| `services_password` | Defines the services password used by the agent to connect to the Console server | String |
| `console_port` | Defines the port used by the Tripwire Enterprise console to connect the agent to the console | String |
| `install_directory` | Defines the directory the agent will be installed to on the target system | String |
| `install_rtm` | Tells the installer not to install EG services | Boolean |
| `rtm_port` | Defines the local port used by the EG services | Integer |
| `proxy_agent` | Configures the agent to become a proxy for other agents | Boolean |
| `proxy_hostname` | Defines the hostname or IP of another Java agent serving as a proxy to the Tripwire Enterprise Console | String |
| `proxy_port` | Defines the proxy port used by the proxy or to connect to a Java proxy agent | Integer |
| `fips` | Tells the installer to enable FIPS mode | Boolean |
| `integration_port` | Defines the integration port, if FIPS is set | Integer |
| `start_service` | Defines if the service starts once the agent is installed | Boolean |
| `tags` | Key/Value hash of tag sets and tags used when the agent first registers to the Tripwire Enterprise console | Hash |

### Java Actions

* `:install` - Default action, Installs the Java agent
* `:remove` - Removes the java agent

### Required properties

*Java*
* installer
* console
* services_password

*Axon*
* installer
* eg_driver_installer (if installing EG/RTM, linux/debian only)
* eg_service_installer (if installing EG/RTM, linux/debain only)
* dns_srvc_name (if using DNS to direct agent to the bridge)
* dns_srvc_domain (if using DNS)
* bridge_server (if providing the IP/Hostname of the bridge)
* keystore_password (if using PKI)
* registration_key (if using a registration key to authenticate to the bridge)

## Attributes

| Key | Type | Description | Default | Java Required | Axon Required |
|-----|------|-------------|---------|---------------| --------------|
| ['tripwire_agent']['installer'] | String | Path to the agent installer binary or original compressed tar/zip archive, accepts http and file paths | nil | Yes | Yes |
| ['tripwire_agent']['tags'] | Hash | Hash of tag sets and tags applied when the agent registers | {} | No | No |
| ['tripwire_agent']['proxy_hostname'] | String | Hostname/IP of the proxy server used by the agent | nil | No | No |
| ['tripwire_agent']['proxy_port'] | Integer | Proxy's listening port | 1080 | No | No |
| ['tripwire_agent']['install_rtm'] | Boolean | Installs Real-Time monitoring modules | true | No | No |
| ['tripwire_agent']['rtm_port'] | Integer | Port used by the Real-Time service | 1169 | No | No |
| ['tripwire_agent']['start_service'] | Boolean | Starts the agent once installation completes | true | No | No |
| ['tripwire_agent']['java']['console'] | String | Tripwire Enterprise hostname/IP | nil | Yes | - |
| ['tripwire_agent']['java']['services_password'] | String | Services password  required to connect the java agent to the Tripwire Enterprise Console | nil | Yes | - |
| ['tripwire_agent']['java']['console_port'] | Integer | Port used by both the agent and console for communication | 9898 | No | - |
| ['tripwire_agent']['java']['proxy_agent'] | Boolean | Configures the agent to be a proxy | false | No | - |
| ['tripwire_agent']['java']['fips'] | Boolean | Enables FIPS mode on the java agent | false | No | - |
| ['tripwire_agent']['java']['integration_port'] | Integer | Configures the integration port used by the Tripwire Enterprise Console, only set if FIPS is enabled | 8080 | No | - |
| ['tripwire_agent']['java']['install_directory'] | String | Modifies the default installation directory for the agent | Windows: `C:\Program Files\Tripwire\TE\Agent` Linux: `/usr/local/tripwire/te/agent` | No | - |
| ['tripwire_agent']['axon']['eg_install'] | Boolean | Install the event generator driver and the eveng generator service (linux/debian only) | Yes | - | Yes |
| ['tripwire_agent']['axon']['use_dkms_driver'] | Boolean | If a tar file was set for the `installer` and `eg_install` is set to `true`, this flag instructs to install the DKMS driver if set to true | false | - | No |
| ['tripwire_agent']['axon']['eg_driver_installer'] | String | Event Generator installer for linux | nil | - | No |
| ['tripwire_agent']['axon']['eg_service_installer'] | String | Event Generator service installer for linux | nil | - | No |
| ['tripwire_agent']['axon']['service_name'] | String | Service name for Axon | Linux: `tripwire-axon-agent`, Windows: `TripwireAxonAgent` | - | No |
| ['tripwire_agent']['axon']['config_directory'] | String | Path to the configuration directory for Axon | Linux: `/etc/tripwire`, Windows: `C:\Program Files\Tripwire\Agent` |  - | No |
| ['tripwire_agent']['axon']['bridge'] | String | Hostname or IP of the bridge server | nil | - | Yes |
| ['tripwire_agent']['axon']['bridge_port'] | Integer | Bridge port listening for Axon agents | 5670 | - | No |
| ['tripwire_agent']['axon']['dns_srvc_name'] | String | PTR used by axon to connect to the bridge | _tw_gw | No | No |
| ['tripwire_agent']['axon']['dns_srvc_domain'] | String | Domain to find the PTR to connect to the bridge | nil | No | No |
| ['tripwire_agent']['axon']['bridge_auth_mode'] | String | Method used to register with the bridge, registration or pki | registration | - | No |
| ['tripwire_agent']['axon']['keystore_password'] | String | Password used to unlock the PKI keystore | nil | - | No |
| ['tripwire_agent']['axon']['registration_filename'] | String | File name used for the registration key file | registration_pre_shared_key.txt | - | No |
| ['tripwire_agent']['axon']['proxy_username'] | String | Username to authenticate to the Axon proxy | nil | - | No |
| ['tripwire_agent']['axon']['proxy_password'] | String | Password to authenticate to the Axon proxy | nil | - | No |
| ['tripwire_agent']['axon']['tls_version'] | String | TLS version(s) used by the Axon agent will use connecting to the bridge | nil | - | No |
| ['tripwire_agent']['axon']['cipher_suites'] | String | Cipher suites the Axon agent will use connecting to the bridge | nil | - | No |
| ['tripwire_agent']['axon']['spool_size'] | String | Set a custom spool size | 1g | - | No |
| ['tripwire_agent']['axon']['clean'] | Boolean | Used in uninstalling the agent to clean up the configuration directory | true | - | No |

## Provider Usage

### Axon

Place this dependency inside your cookbooks metadata.rb.

```ruby
depends 'tripwire_agent'
```

Within your recipe specifying all of the installer binaries:

```ruby
tripwire_agent_axon 'Installing the Tripwire Axon Agent' do
  installer '/mnt/share/tripwire/axon-agent-installer-linux-x64.rpm'
  eg_driver_installer '/mnt/share/tripwire/tw-eg-driver.x86_64.rpm'
  eg_service_installer '/mnt/share/tripwire/tw-eg-service.x86_64.rpm'
  bridge 'tw-console.example.com'
  registration_key 'PaS5w0rd!_K3y'
  tags {"Platform": "Red Hat", "Policy": ["PCI", "SOX"], "Importance": "High", "Org": ["Payment", "Sales", "Production"]}
end
```

Within your recipe specifying the packaged tar file from Tripwire Customer Center:
```ruby
tripwire_agent_axon 'Installing the Tripwire Axon Agent' do
  installer '/mnt/share/tripwire/axon-agent-installer-linux-x64.tgz'
  bridge 'tw-console.example.com'
  registration_key 'PaS5w0rd!_K3y'
  tags {"Platform": "Red Hat", "Policy": ["PCI", "SOX"], "Importance": "High", "Org": ["Payment", "Sales", "Production"]}
end
```

The configurations above will install the Axon agent, EG Driver, EG Service onto the platform. The twagent.conf file will be set to point to the bridge server and sets a registration password file (This file will be removed once the agent successfully registers with the bridge). Tagging file will also be created and will be used only once during the first time the agent connects to the bridge for Tripwire Enterprise.

### Java

Place this dependency inside your cookbooks metadata.rb.

```ruby
depends 'tripwire_agent'
```

Within your recipe:

```ruby
tripwire_agent_java 'Install Tripwire Java Agent' do
  installer '/mnt/share/tripwire/te_agent.bin'
  console 'tw-console.example.com'
  services_password 'Pas5W0rd!_C0mp13x!Ty^'
  tags {"Platform": "Red Hat", "Policy": ["PCI", "SOX"], "Importance": "High", "Org": ["Payment", "Sales", "Production"]}
end
```

The configuration above will install the Tripwire Java agent and point it at the Tripwire Enterprise console. It will register with a hash of tags when the agent first registers to the console server.

## Recipe Usage

### Axon

Sample Installation Role:

```yaml
chef_type:                  role
default_attributes:
description:                Axon agent install for Linux, no DNS record
env_run_lists:
json_class:                 Chef::Role
name:                       axon_install_linux_x64
override_attributes:
  tripwire_agent:
    installer:              '/mnt/share/tripwire/axon-agent-installer-linux-x64.tgz'
    tags:                   {"Platform": "Red Hat", "Policy": ["PCI", "SOX"], "Importance": "High", "Org": ["Payment", "Sales", "Production"]}
    axon:
      bridge:               'tw-console.example.com'
      registration_key:     'PaS5w0rd!_K3y'
run_list:
  recipe[tripwire_agent::axon_agent]
```

Sample Migration Role:

```yaml
chef_type:                  role
default_attributes:
description:                Axon agent install for Linux, no DNS record
env_run_lists:
json_class:                 Chef::Role
name:                       axon_install_linux_x64
override_attributes:
  tripwire_agent:
    installer:              '/mnt/share/tripwire/axon-agent-installer-linux-x64.tgz'
    tags:                   {"Platform": "Red Hat", "Policy": ["PCI", "SOX"], "Importance": "High", "Org": ["Payment", "Sales", "Production"]}
    axon:
      bridge:               'tw-console.example.com'
      registration_key:     'PaS5w0rd!_K3y'
run_list:
  recipe[tripwire_agent::migrate]
```

### Java

Java recipes include a removal recipe and an installation recipe.

Sample Role:

```yaml
chef_type:                  role
default_attributes:
description:                Java agent install for Linux
env_run_lists:
json_class:                 Chef::Role
name:                       java_install_linux_x64
override_attributes:
  tripwire_agent:
    installer:              '/mnt/share/tripwire/te_agent.bin'
    tags:                   {"Platform": "Red Hat", "Policy": ["PCI", "SOX"], "Importance": "High", "Org": ["Payment", "Sales", "Production"]}
    java:
      console:              'tw-console.example.com'
      services_password:    'Pas5W0rd!_C0mp13x!Ty^'
run_list:
  recipe[tripwire_agent::java_agent]
```

## To-Do

* Support custom pki registration

## Gotchas

* Axon agents requires some method of knowing about the bridge, either through DNS pointer record or manually configuring the bridge through the attribute or when using the resource in your cookbook.
  * Please see the Installation and Maintenance guide for any additional information
* Installation of the DKMS driver for the event generator service requires that the DKMS package is already installed on the system.
* Axon Windows agents will automatically start post installation
  * Linux Axon agents can be prevented from starting post installation
  * Java agents for Windows and Linux can be prevented from starting post installation
* Alternative installation paths for Java agents are not supported on Debian platforms
* Alternative installation paths on Axon are currently not supported
* Integration Port for Java agents will only be set if FIPS is enabled

## Contributing

See the [contribution guidelines](https://github.com/Tripwire/chef-tripwire_agent/blob/master/CONTRIBUTING.md) for more information.
