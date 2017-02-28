require 'spec_helper'

describe CleverTap::FailedResponse do
  let(:records) { [{ 'id' => 1 }, { 'id' => 2 }] }
  let(:message) { 'LOL an error' }
  let(:code) { 401 }

  subject { described_class.new(records: records, message: message, code: code) }

  describe '#status' do
    it { expect(subject.status).to eq 'fail' }
  end

  describe '#success' do
    it { expect(subject.success).to be false }
  end

  describe '#errors' do
    it do
      error = { 'status' => 'fail', 'code' => code, 'error' => message }

      expect(subject.errors).to match_array(
        records.map { |r| error.merge('record' => r) }
      )
    end
  end

  describe '#message' do
    it { expect(subject.message).to eq message }
  end
end
