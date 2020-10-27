require 'spec_helper'
require 'shared/clever_tap_client'

describe CleverTap::Client, vcr: true do
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

  describe '#new' do
    let(:identity_field) { 'ID' }
    let(:account_id) { 'ABC1234' }
    let(:account_passcode) { 'AcCPasScoDe123' }

    context 'when credentials set in `CleverTap.setup`' do
      subject { CleverTap::Client.new }

      before do
        CleverTap.setup do |config|
          config.identity_field = identity_field
          config.account_id = account_id
          config.account_passcode = account_passcode
        end
      end

      it_behaves_like 'configured `Client`'
    end

    context 'when credentials set in `CleverTap::Client.new`' do
      subject { CleverTap::Client.new(account_id, account_passcode) }
      it_behaves_like 'configured `Client`'
    end
  end

  def event_factory(id, name)
    CleverTap::Event.new(
      data: { 'FBID' => id.to_s, 'Name' => name.to_s },
      name: 'Web Event',
      identity: 'FBID'
    )
  end

  def profile_factory
    CleverTap::Profile.new(
      data: { 'ID' => '1414', 'Name' => 'John', 'Phone' => '+44+441234' }
    )
  end

  describe '#upload' do
    let(:success_proc) { proc { 'sample proc' } }
    let(:response) { subject.upload([event1, event2]) }

    subject do
      client = described_class.new
      client.on_successful_upload(&success_proc)
      client
    end

    before do
      CleverTap.setup do |c|
        c.identity_field = 'ID'
        c.account_id = AUTH_ACCOUNT_ID
        c.account_passcode = AUTH_PASSCODE
      end
    end

    context 'when upload records are homogenous' do
      context 'and valid records' do
        let(:event1) { event_factory('1414', 'John') }
        let(:event2) { event_factory('1515', 'Jill') }

        context 'and objects fit `upload_limit`' do
          VCR.use_cassette('upload within Event limit') do
            it 'returns an array with one successful `Response` object' do
              expect(response.count).to eq 1
              expect(response.first.success).to be true
              expect(response.first).to be_a(CleverTap::Response)
            end

            it 'calls `on_successful_upload` proc once' do
              expect(success_proc).to receive(:call).once
              subject.upload([event1, event2])
            end
          end
        end

        context 'and objects do not fit `upload_limit`' do
          before do
            allow(CleverTap::Event)
              .to receive(:upload_limit).and_return(1)
          end

          VCR.use_cassette('upload out of Event limit') do
            it 'returns an array with two successful `Response` objects' do
              expect(response.count).to eq 2
              expect(response.all?(&:success)).to be true
              expect(
                response.all? { |r| r.class == CleverTap::Response }
              ).to be true
            end

            it 'calls `on_successful_upload` proc twice' do
              expect(success_proc).to receive(:call).twice
              subject.upload([event1, event2])
            end
          end
        end
      end

      context 'and invalid records' do
        let(:failure_proc) { proc { 'sample proc' } }
        let(:response) { subject.upload([profile]) }

        subject do
          client = described_class.new
          client.on_failed_upload(&failure_proc)
          client
        end

        let(:profile) { profile_factory }

        it 'returns an array with one failed `Response` object' do
          expect(response.count).to eq 1
          expect(response.first.class).to eq CleverTap::Response
          expect(response.first.success).to be false
        end

        it 'calls `on_failed_upload` once' do
          expect(failure_proc).to receive(:call).once
          subject.upload([profile])
        end
      end
    end

    context 'when objects are not homogenous' do
      let(:event1) { event_factory('1414', 'John') }
      let(:event2) { {} }

      it 'raises `NotConsistentArrayError`' do
        expect { subject.upload([event1, event2]) }.to raise_error CleverTap::NotConsistentArrayError
      end
    end
  end

  describe '#request_body' do
    subject { described_class.new('123456', 'passcode') }
    let(:records) do
      [
        { 'ID' => '123', 'Name' => 'John' },
        { 'ID' => '456', 'Name' => 'Jill' }
      ]
    end

    it 'converts records hash to json' do
      expect(subject.send(:request_body, records))
        .to eq({ 'd' => records }.to_json)
    end
  end

  describe '#determine_type' do
    subject { described_class.new('123456', 'passcode') }

    context 'when records are of the same type' do
      let(:records) { [{}, {}] }

      it 'returns the class of the elements' do
        expect(subject.send(:determine_type, records)).to eq Hash
      end
    end

    context 'when records are of different type' do
      let(:records) { [{}, []] }

      it 'raises `NotConsistentArrayError`' do
        expect { subject.send(:determine_type, records) }.to raise_error CleverTap::NotConsistentArrayError
      end
    end
  end

  describe '#ensure_array' do
    subject { described_class.new('123456', 'passcode') }
    let(:records) { %w[sample sample2] }
    let(:record) { 'sample' }

    it 'returns an array when an array passed' do
      expect(subject.send(:ensure_array, records)).to eq records
    end

    it 'returns an array when a single element passed' do
      expect(subject.send(:ensure_array, record)).to eq [record]
    end
  end

  describe 'setting `account_id` and `passcode`' do
    subject { described_class.new(client_id, client_passcode) }
    let(:client_id) { '123456' }
    let(:client_passcode) { 'passcode' }
    let(:config_id) { 'config_account_id' }
    let(:config_passcode) { 'config_passcode' }

    def config_client(account, pass)
      CleverTap.setup do |c|
        c.account_id = account
        c.account_passcode = pass
      end
    end

    context 'when credentials provided in configuration' do
      before { config_client(config_id, config_passcode) }

      context 'and in initialization as well' do
        it 'has initialization values' do
          expect(subject.send(:assign_account_id, client_id)).to eq client_id
          expect(subject.send(:assign_passcode, client_passcode)).to eq client_passcode
        end
      end

      context 'and not in initialization' do
        it 'has initialization values' do
          expect(subject.send(:assign_account_id, nil)).to eq config_id
          expect(subject.send(:assign_passcode, nil)).to eq config_passcode
        end
      end
    end

    context 'when credentials not provided in configuration' do
      before { config_client(nil, nil) }

      context 'but provided in initialization' do
        it 'has initialization values' do
          expect(subject.send(:assign_account_id, client_id)).to eq client_id
          expect(subject.send(:assign_passcode, client_passcode)).to eq client_passcode
        end
      end

      context 'and not provided in initialization as well' do
        before { config_client(nil, nil) }
        subject { described_class.new }

        it 'raises a `RuntimeError` error' do
          expect { subject }.to raise_error RuntimeError
        end
      end
    end
  end

  describe '#receivers_chunks' do
    before do
      stub_const('CleverTap::Campaign::MAX_USERS_PER_CAMPAIGN', 4)
    end

    subject { described_class.new(AUTH_ACCOUNT_ID, AUTH_PASSCODE) }

    context 'when the number of targets is greater than MAX_USERS_PER_CAMPAIGN' do
      context 'the number of targets is not divisible by limit' do
        let(:campaign) do
          CleverTap::Campaign::Sms.new(
            to: {
              'FBID' => %w[a1 a2 a3 a4 a5],
              'Email' => %w[b1 b2 b3],
              'Identity' => %w[c1 c2 c3 c4 c5],
              'objectId' => %w[d1 d2 d3 d4 d5]
            },
            tag_group: 'mytaggroup',
            respect_frequency_caps: false,
            content: { 'body' => 'Smsbody' }
          )
        end

        it 'should yield 5 times' do
          expect { |b| subject.send(:receivers_chunks, campaign, &b) }.to yield_control.exactly(5).times
        end
      end

      context 'just an identity and it does not exeed the limit' do
        let(:campaign) do
          CleverTap::Campaign::Sms.new(
            to: {
              'FBID' => %w[a1 a2 a3]
            },
            tag_group: 'mytaggroup',
            respect_frequency_caps: false,
            content: { 'body' => 'Smsbody' }
          )
        end

        it 'should yield 1 times' do
          expect { |b| subject.send(:receivers_chunks, campaign, &b) }.to yield_control.exactly(1).times
        end
      end

      context 'the set of identities does not exeed the limit' do
        let(:campaign) do
          CleverTap::Campaign::Sms.new(
            to: {
              'FBID' => %w[a1],
              'Email' => %w[b1],
              'Identity' => %w[c1],
              'objectId' => %w[d1]
            },
            tag_group: 'mytaggroup',
            respect_frequency_caps: false,
            content: { 'body' => 'Smsbody' }
          )
        end

        it 'should yield 1 times' do
          expect { |b| subject.send(:receivers_chunks, campaign, &b) }.to yield_control.exactly(1).times
        end
      end

      context 'empty targets' do
        let(:campaign) do
          CleverTap::Campaign::Sms.new(
            to: {
              'FBID' => %w[],
              'Email' => %w[],
              'Identity' => %w[],
              'objectId' => %w[]
            },
            tag_group: 'mytaggroup',
            respect_frequency_caps: false,
            content: { 'body' => 'Smsbody' }
          )
        end

        it 'should yield 0 times' do
          expect { |b| subject.send(:receivers_chunks, campaign, &b) }.to yield_control.exactly(0).times
        end
      end
    end
  end

  describe '#create_campaign' do
    before do
      stub_const('CleverTap::Campaign::MAX_USERS_PER_CAMPAIGN', 4)
    end

    subject { described_class.new(AUTH_ACCOUNT_ID, AUTH_PASSCODE).create_campaign(campaign) }

    context 'when the number of targets is greater than MAX_USERS_PER_CAMPAIGN' do
      context 'the number of targets is not divisible by limit' do
        let(:campaign) do
          CleverTap::Campaign::Sms.new(
            to: {
              'FBID' => %w[a1 a2 a3 a4 a5],
              'Email' => %w[b1 b2 b3],
              'Identity' => %w[c1 c2 c3 c4 c5],
              'objectId' => %w[d1 d2 d3 d4 d5]
            },
            tag_group: 'mytaggroup',
            respect_frequency_caps: false,
            content: { 'body' => 'Smsbody' }
          )
        end

        it 'should return an array of 5 responses' do
          expect(subject.size).to eq 5
          subject.each do |result|
            body = JSON.parse(result.body)
            expect(result.success?).to be_truthy
            expect(result.status).to eq(200)
            expect(body).to include('message' => 'Added to queue for processing', 'status' => 'success')
          end
        end
      end

      context 'just an identity and it does not exeed the limit' do
        let(:campaign) do
          CleverTap::Campaign::Sms.new(
            to: {
              'FBID' => %w[a1 a2 a3]
            },
            tag_group: 'mytaggroup',
            respect_frequency_caps: false,
            content: { 'body' => 'Smsbody' }
          )
        end

        it 'should return an array of 1 responses ' do
          expect(subject.size).to eq 1
          subject.each do |result|
            body = JSON.parse(result.body)
            expect(result.success?).to be_truthy
            expect(result.status).to eq(200)
            expect(body).to include('message' => 'Added to queue for processing', 'status' => 'success')
          end
        end
      end

      context 'the set of identities does not exeed the limit' do
        let(:campaign) do
          CleverTap::Campaign::Sms.new(
            to: {
              'FBID' => %w[a1],
              'Email' => %w[b1],
              'Identity' => %w[c1],
              'objectId' => %w[d1]
            },
            tag_group: 'mytaggroup',
            respect_frequency_caps: false,
            content: { 'body' => 'Smsbody' }
          )
        end

        it 'should return an array of 1 responses' do
          expect(subject.size).to eq 1
          subject.each do |result|
            body = JSON.parse(result.body)
            expect(result.success?).to be_truthy
            expect(result.status).to eq(200)
            expect(body).to include('message' => 'Added to queue for processing', 'status' => 'success')
          end
        end
      end

      context 'empty targets' do
        let(:campaign) do
          CleverTap::Campaign::Sms.new(
            to: {
              'FBID' => %w[],
              'Email' => %w[],
              'Identity' => %w[],
              'objectId' => %w[]
            },
            tag_group: 'mytaggroup',
            respect_frequency_caps: false,
            content: { 'body' => 'Smsbody' }
          )
        end

        it 'should return an empty array' do
          expect(subject.size).to eq 0
        end
      end
    end

    context 'when the number of targest does not exeed the limit' do
      let(:campaign) do
        CleverTap::Campaign::Sms.new(
          to: {
            'FBID' => %w[a1],
            'Email' => %w[b1],
            'Identity' => %w[c1],
            'objectId' => %w[d1]
          },
          tag_group: 'mytaggroup',
          respect_frequency_caps: false,
          content: { 'body' => 'Smsbody' }
        )
      end

      it 'should return a single response' do
        expect(subject.size).to eq 1
        subject.each do |result|
          body = JSON.parse(result.body)
          expect(result.success?).to be_truthy
          expect(result.status).to eq(200)
          expect(body).to include('message' => 'Added to queue for processing', 'status' => 'success')
        end
      end
    end
  end
end
