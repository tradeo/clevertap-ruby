require 'spec_helper'

RSpec.describe CleverTap do
  describe '#new' do
    context 'with valid arguments' do
      context 'with keyword arguments' do
        subject(:clever_tap) do
          CleverTap.new(account_id: 'foo',
                        passcode: 'passcode',
                        identity_field: 'ID',
                        configure_faraday: configure_faraday)
        end

        let(:configure_faraday) { proc {} }

        it('persist the account_id') { expect(clever_tap.config.account_id).to eq('foo') }
        it('persist the passcode') { expect(clever_tap.config.passcode).to eq('passcode') }
        it('persist the identity field') { expect(clever_tap.config.identity_field).to eq('ID') }
        it('persist the faraday config') { expect(clever_tap.config.configure_faraday).to eq(configure_faraday) }
      end

      context 'with block' do
        subject(:clever_tap) do
          CleverTap.new do |config|
            config.account_id = 'foo'
            config.passcode = 'passcode'
            config.identity_field = 'ID'
            config.configure_faraday(&configure_faraday)
          end
        end

        let(:configure_faraday) { proc {} }

        it('persist the account_id') { expect(clever_tap.config.account_id).to eq('foo') }
        it('persist the passcode') { expect(clever_tap.config.passcode).to eq('passcode') }
        it('persist the identity field') { expect(clever_tap.config.identity_field).to eq('ID') }
        it('persist the faraday config') { expect(clever_tap.config.configure_faraday).to eq(configure_faraday) }
      end
    end

    context 'with invalid arguments' do
      it 'require `account_id`' do
        expect { CleverTap.new(passcode: 'foo') }
          .to raise_error(RuntimeError, /account_id/)
      end

      it 'require `passcode`' do
        expect { CleverTap.new(account_id: 'bar') }
          .to raise_error(RuntimeError, /passcode/)
      end
    end
  end

  describe '#client' do
    subject(:clever_tap) { CleverTap.new(account_id: 'foo', passcode: 'passcode', &configure_faraday) }
    let(:configure_faraday) { proc { |_faraday| } }

    it 'initialize client with a right auth data' do
      expect(CleverTap::Client).to receive(:new).with('foo', 'passcode', &configure_faraday)

      clever_tap.client
    end

    it 'cache the client between calls' do
      id = clever_tap.client.object_id
      expect(clever_tap.client.object_id).to eq(id)
    end
  end
end
