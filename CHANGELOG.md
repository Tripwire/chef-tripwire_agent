# tripwire_agent Cookbook CHANGELOG

## 0.1.5 (2017-11-10)

Expanding axon's resources to support co-existing agents for TE, TLC, and IP360
Added service_name, install_directory, and config_directory property to allow
users to set the paths necessary for proper configuration of the agent.

- Inspec tests added for IP360's path changes
- Updated README

Fixes to enable axon to be used as a resource in other cookbooks:
- Template resource now includes the cookbook name
- Set proxy_hostname to nil (not sure why I changed it to string)
  - fix in both the template and attributes

## 0.1.4 (2017-10-27)

Resolved nil issue when using the Java agent resource

Added new_resource to all properties in Axon and Java resources for Chef 13 support

## 0.1.3 (2017-10-02)

Resolved a issue with event generator driver/service for linux throwing an error if paths to the installers are not present in Axon

Resolved an issue with the DNS pointer being used when left at its default value

## 0.1.2 (2017-06-29)

Fix supported Chef version.

## 0.1.1 (2017-06-22)

Formatting fixes for documentation. No code changes.

## 0.1.0 (2017-06-22)

The first version released on GitHub and Chef Supermarket
