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

  describe 'customisations' do
    context 'with different adapter' do
      subject do
        described_class.new('123456', 'passcode') { |config| config.adapter(:test) }
      end

      it 'override the default adapter' do
        handlers = subject.connection.builder.handlers

        expect(handlers.count).to eq(1)
        expect(handlers.first).to eq(Faraday::Adapter::Test)
      end
    end

    context 'without an adapter' do
      subject { described_class.new('123456', 'passcode') }

      it 'use Net::HTTP adapter' do
        handlers = subject.connection.builder.handlers

        expect(handlers.count).to eq(1)
        expect(handlers.first).to eq(Faraday::Adapter::NetHttp)
      end
    end
  end
end
