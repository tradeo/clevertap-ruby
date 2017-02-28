require 'spec_helper'

RSpec.describe CleverTap do
  # NOTE: clear mutations in CleverTap config
  after do
    CleverTap.instance_variable_set('@config', nil)
    CleverTap.instance_variable_set('@client', nil)
  end

  describe '#configure' do
    it 'persist all settings' do
      CleverTap.configure(account_id: 'foo', passcode: 'passcode')

      expect(CleverTap.config).to eq(account_id: 'foo', passcode: 'passcode')
    end

    it 'require `account_id`' do
      expect { CleverTap.configure(passcode: 'foo') }
        .to raise_error(ArgumentError, /account_id/)
    end

    it 'require `passcode`' do
      expect { CleverTap.configure(account_id: 'bar') }
        .to raise_error(ArgumentError, /passcode/)
    end
  end

  describe '#client' do
    before { CleverTap.configure(account_id: 'foo', passcode: 'passcode') }

    it 'initialize client with a right auth data' do
      expect(CleverTap::Client).to receive(:new).with('foo', 'passcode')

      CleverTap.client
    end

    it 'cache the client between calls' do
      id = CleverTap.client.object_id
      expect(CleverTap.client.object_id).to eq(id)
    end
  end
end
