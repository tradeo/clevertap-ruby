require 'spec_helper'

RSpec.describe CleverTap::Campaign::Email do
  describe '#to_h' do
    subject { described_class.new(**params).to_h }

    let(:params) do
      {
        to: {
          'Email' => ['example@email.com'],
          'FBID' => ['fbidexample']
        },
        tag_group: 'my tag group',
        respect_frequency_caps: false,
        content: {
          'subject' => 'Welcome',
          'body' => '<div>Your HTML content for the email</div>',
          'sender_name' => 'CleverTap'
        }
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

    context 'When content does not have body' do
      before do
        params[:content].delete 'body'
      end

      it 'should raise a NoContentError error' do
        expect { subject }.to raise_error(CleverTap::NoContentError)
      end
    end

    context 'When content does not have sender_name' do
      before do
        params[:content].delete 'sender_name'
      end

      it 'should raise a NoContentError error' do
        expect { subject }.to raise_error(CleverTap::NoContentError)
      end
    end

    context 'When content does not have subject' do
      before do
        params[:content].delete 'subject'
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
