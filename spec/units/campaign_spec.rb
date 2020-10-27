require 'spec_helper'

RSpec.describe CleverTap::Campaign do
  describe '#to_h' do
    subject { described_class.new(**params).to_h }

    let(:params) do
      {
        to: {
          'Email' => ['example@email.com'],
          'FBID' => ['fbidexample']
        },
        tag_group: 'mytaggroup',
        respect_frequency_caps: false,
        content: { 'body' => 'Smsbody' }
      }
    end

    let(:parsed_params) { Hash[params.map { |k, v| [k.to_s, v] }] }

    context "When 'to' key is not defined" do
      let(:params) do
        {
          tag_group: 'mytaggroup',
          respect_frequency_caps: false,
          content: { 'body' => 'Smsbody' }
        }
      end

      it 'should raise a ArgumentError error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context "When 'to' key is empty" do
      let(:params) do
        {
          to: {},
          tag_group: 'mytaggroup',
          respect_frequency_caps: false,
          content: { 'body' => 'Smsbody' }
        }
      end

      it 'should raise a NoReceiversError error' do
        expect { subject }.to raise_error(CleverTap::NoReceiversError)
      end
    end

    context 'When identity key into to is invalid' do
      let(:params) do
        {
          to: {
            'BadIdentity' => ['example']
          },
          tag_group: 'mytaggroup',
          respect_frequency_caps: false,
          content: { 'body' => 'Smsbody' }
        }
      end

      it 'should raise a InvalidIdentityTypeError error' do
        expect { subject }.to raise_error(CleverTap::InvalidIdentityTypeError)
      end
    end

    context 'When indentity keys are empty' do
      let(:params) do
        {
          to: {
            'FBID' => [],
            'Email' => [],
            'Identity' => [],
            'objectId' => []
          },
          tag_group: 'mytaggroup',
          respect_frequency_caps: false,
          content: { 'body' => 'Smsbody' }
        }
      end

      it 'should raise a NoReceiversError error' do
        expect { subject }.to raise_error(CleverTap::NoReceiversError)
      end
    end

    context 'When content is not sent' do
      before do
        params.delete :content
      end

      it 'should raise a ArgumentError error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'When users per campaign limit was exceeded' do
      let(:params) do
        {
          to: {
            'Email' => ['example@email.com'] * 100,
            'FBID' => ['fbidexample'] * 901
          },
          tag_group: 'mytaggroup',
          respect_frequency_caps: false,
          content: { 'body' => 'Smsbody' }
        }
      end

      it 'should raise a ReceiversLimitExceededError error' do
        expect { subject }.to raise_error(CleverTap::ReceiversLimitExceededError)
      end
    end
  end
end
