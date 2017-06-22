#
# Cookbook:: tripwire_agent
# Spec:: default
#

require 'spec_helper'

test_systems = {
  ubuntu: '16.04',
  centos: '6.9',
}

test_systems.each do |test_platform, test_version|
  describe 'tripwire_agent::java_agent' do
    context 'Default attributes on ' + test_platform do
      let(:chef_run) do
        runner = ChefSpec::ServerRunner.new(platform: test_platform, version: test_version)
        runner.converge(described_recipe)
      end

      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end

      it 'copies the agent to the local cache' do

      end

      it 'writes the java ttagging template file' do

      end

      it 'installs the agent to the local system' do

      end

      it 'starts the rtm service' do

      end

      it 'starts the agent service' do

      end

      it 'deletes the agent installer from the local cache' do

      end
    end
  end
end
