require 'spec_helper'

describe CleverTap::Client do
  subject { described_class.new('123456', 'passcode') }

  describe 'authentication' do
    it 'send right `account_id`' do
      expect(subject.connection.headers['X-CleverTap-Account-Id']).to eq('123456')
    end

    it 'send right `passcode`' do
      expect(subject.connection.headers['X-CleverTap-Passcode']).to eq('passcode')
    end
  end
end
