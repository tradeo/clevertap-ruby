require 'spec_helper'
require 'shared/entity'

RSpec.describe CleverTap::Profile do
  describe '.upload_limit' do
    subject { described_class.upload_limit }
    it { is_expected.to eq 100 }
  end

  describe '#to_h' do
    subject { described_class.new(**params).to_h }

    describe 'choosing `identity`' do
      it_behaves_like 'choosing identity for', 'profile'
    end

    describe 'choosing timestamp' do
      it_behaves_like 'choosing timestamp'
    end

    describe 'type' do
      it_behaves_like 'proper type'
    end

    describe 'data' do
      it_behaves_like 'constructing data for', 'profile'
    end
  end
end
