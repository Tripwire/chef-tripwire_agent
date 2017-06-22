# Testing tripwire_agent Cookbook


## Testing Prerequisites

A working ChefDK installation set as your system's default ruby. ChefDK can be downloaded at <https://downloads.chef.io/chef-dk/>

Hashicorp's [Vagrant](https://www.vagrantup.com/downloads.html) and Oracle's [Virtualbox](https://www.virtualbox.org/wiki/Downloads) for integration testing.

## Installing dependencies

Cookbooks may require additional testing dependencies that do not ship with ChefDK directly. These can be installed into the ChefDK ruby environment with the following commands

Install dependencies:

```shell
chef exec bundle install
```

Update any installed dependencies to the latest versions:

```shell
chef exec bundle update
```

### Linting

The lint stage runs Ruby specific code linting using cookstyle (<https://github.com/chef/cookstyle>).

`chef exec cookstyle . -lint`

### Syntax Testing

The syntax stage runs Chef cookbook specific linting and syntax checks with Foodcritic (<http://www.foodcritic.io/>).

`foodcritic . --tags correctness,metadata`

## Unit stage

Currently there are no unit tests written

## Integration Testing

Integration testing is performed by Test Kitchen. You will need to add your own boxes and provider to the kitchen file provided to run tests. Testing will validate basic and more comprehensive installations.

## Integration Testing using Vagrant

Integration tests can be performed on a local workstation using either VirtualBox or VMWare as the virtualization hypervisor. To run tests against all available instances run:

```shell
chef exec kitchen test
`
```

To see a list of available test instances run:

```shell
chef exec kitchen list
```

To test specific instance run:

```shell
chef exec kitchen test INSTANCE_NAME
```

## Example kitchen.yml - Basic Integration Tests

```yaml
---
driver:
  name: vagrant

provisioner:
  name: chef_zero
  require_chef_omnibus: true
  chef_omnibus_url: https://www.chef.io/chef/install.sh
  always_update_cookbooks: true

verifier:
  name: inspec

platforms:
  - name: a_linux_type
  - name: a_windows_type
  - name: a_debian_type

# Testing Linux Basics
- name: java-linux-basic
  run_list:
    - recipe[tripwire_agent::java_agent]
  verifier:
    inspec_tests:
      - test/smoke/java-basic
  excludes:
    - a_windows_type
    - a_debian_type
  attributes:
    tripwire_agent:
      installer: '/path/to/te_agent.bin'
      tags: { "tag_set1": [ "1_tag1", "1_tag2" ], "tag_set2": "2_tag1" }
      java:
        console: 'console.example.com'
        services_password: 'P@s5w0rd!C0mp13XP@s5w0rD!'

- name: axon-linux-basic
  run_list:
    - recipe[tripwire_agent::axon_agent]
  verifier:
    inspec_tests:
      - test/smoke/axon-basic
  excludes:
    - a_windows_type
    - a_debian_type
  attributes:
    tripwire_agent:
      installer: '/path/to/axon-agent-installer-linux-x64.rpm'
      axon:
        eg_driver_installer: '/path/to/tw-eg-driver-rhel-1.3.313-1.x86_64.rpm'
        eg_service_installer: '/path/to/tw-eg-service-1.3.326-1.x86_64.rpm'
        bridge: 'tw-bridge.example.com'
        registration_key: '123PAs5W0rD'
      tags: { 'tagset1': 'tag1a' , 'tagset2': [ 'tag2a', 'tag2b' ],'tagset3': [ 'tag3a', 'tag3b', 'tag3c' ] }

```
