require 'spec_helper'
require 'shared/entity'

RSpec.describe CleverTap::Event do
  describe '.upload_limit' do
    subject { described_class.upload_limit }
    it { is_expected.to eq 1000 }
  end

  describe '#to_h' do
    subject { described_class.new(**params).to_h }

    describe 'choosing `identity`' do
      it_behaves_like 'choosing identity for', 'event'
    end

    describe 'choosing timestamp' do
      it_behaves_like 'choosing timestamp'
    end

    describe 'event name' do
      let(:data) { { 'FBID' => '1414', 'Name' => 'John' } }
      let(:params) { { data: data, identity: 'FBID' } }

      context 'when `name` is not provided' do
        it { expect { subject }.to raise_error(CleverTap::MissingEventNameError) }
      end

      context 'when `name` is provided' do
        let!(:params_ext) { params.merge!(name: 'Web Event') }
        it { is_expected.to include 'evtName' => 'Web Event' }
      end
    end

    describe 'type' do
      it_behaves_like 'proper type'
    end

    describe 'data' do
      it_behaves_like 'constructing data for', 'event'
    end
  end
end
