require 'spec_helper'

describe CleverTap::SuccessfulResponse do
  shared_context 'successful state' do
    let(:raw_response) do
      { 'status' => 'success', 'processed' => 2, 'unprocessed' => [] }
    end
  end

  shared_context 'partial state' do
    let(:records) { [{ 'id' => 1 }] }
    let(:raw_response) do
      {
        'status' => 'fail',
        'processed' => 1,
        'unprocessed' => records.map { |r| { 'record' => r.to_json } }
      }
    end
  end

  shared_context 'fail state' do
    let(:records) { [{ 'id' => 1 }, { 'id' => 2 }] }
    let(:raw_response) do
      {
        'status' => 'fail',
        'processed' => 0,
        'unprocessed' => records.map { |r| { 'record' => r.to_json } }
      }
    end
  end

  subject { described_class.new(raw_response) }

  describe '#status' do
    context 'with successful status' do
      include_context 'successful state'

      it { expect(subject.status).to eq 'success' }
    end

    context 'with partial status' do
      include_context 'partial state'

      it { expect(subject.status).to eq 'partial' }
    end

    context 'with fail status' do
      include_context 'fail state'

      it { expect(subject.status).to eq 'fail' }
    end
  end

  describe '#success' do
    context 'with successful status' do
      include_context 'successful state'

      it { expect(subject.success).to be true }
    end

    context 'with partial status' do
      include_context 'partial state'

      it { expect(subject.success).to be false }
    end

    context 'with fail status' do
      include_context 'fail state'

      it { expect(subject.success).to be false }
    end
  end

  describe '#errors' do
    context 'with successful status' do
      include_context 'successful state'

      it { expect(subject.errors).to be_empty }
    end

    context 'with partial status' do
      include_context 'partial state'
      it { expect(subject.errors).to all(include('record')) }
    end

    context 'with fail status' do
      include_context 'fail state'

      it { expect(subject.errors).to all(include('record')) }
    end
  end

  describe '#message' do
    context 'with successful status' do
      include_context 'successful state'

      it { expect(subject.message).to eq '' }
    end

    context 'with partial status' do
      include_context 'partial state'

      it { expect(subject.message).to eq '' }
    end

    context 'with fail status' do
      include_context 'fail state'

      it { expect(subject.message).to eq '' }
    end
  end
end
