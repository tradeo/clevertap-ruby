require 'spec_helper'

describe CleverTap::Response do
  let(:success) do
    { 'status' => 'success', 'processed' => 1, 'unprocessed' => [] }
  end

  let(:partial) do
    {
      'status' => 'success',
      'processed' => 1,
      'unprocessed' => [{ '{ "ID" => "5", "Name": "John"}' => 'Some error' }]
    }
  end

  let(:failure) do
    {
      'status' => 'fail',
      'error' => 'Account Id not valid',
      'code' => 401
    }
  end

  describe '#new' do
    subject { described_class.new(response) }

    context 'when successful request' do
      let(:response) { OpenStruct.new(body: success.to_json) }

      it { expect(subject.success).to be true }
      it { expect(subject.failures).to eq [] }
    end

    context 'when partially successful request' do
      let(:response) { OpenStruct.new(body: partial.to_json) }

      it { expect(subject.success).to be false }
      it { expect(subject.failures).to eq partial['unprocessed'] }
    end

    context 'when failed request' do
      let(:response) { OpenStruct.new(body: failure.to_json) }

      it { expect(subject.success).to be false }
      it { expect(subject.failures).to eq [failure] }
    end
  end
end
