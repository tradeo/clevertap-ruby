require 'spec_helper'

RSpec.describe CleverTap::Campaign::Sms do
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

    context 'When content is not sent' do
      before do
        params.delete :content
      end

      it 'should raise a ArgumentError error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'When content does not have body' do
      before do
        params[:content] = {}
      end

      it 'should raise a NoContentError error' do
        expect { subject }.to raise_error(CleverTap::NoContentError)
      end
    end

    context 'success' do
      it { is_expected.to eq parsed_params }
    end
  end
end
