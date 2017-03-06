require 'spec_helper'

shared_examples_for 'validation failure' do |expected_code|
  it 'failed to upload the profiles' do
    result = subject.call(client)
    body = JSON.parse(result.body)

    aggregate_failures 'failed response' do
      expect(result.success?).to be_truthy
      expect(result.status).to eq(200)
      expect(body).to include('processed' => 0,
                              'status' => 'success',
                              'unprocessed' => contain_exactly(
                                a_hash_including('code' => expected_code),
                                a_hash_including('code' => expected_code)
                              ))
    end
  end
end

describe CleverTap::Uploader, vcr: true do
  describe '#call' do
    let(:profile_properties) { [:id, :created_at, :full_name, :last_name, :bta] }
    let(:client) { CleverTap::Client.new(AUTH_ACCOUNT_ID, AUTH_PASSCODE) }

    context 'with valid data' do
      let(:profiles) { [Profile.build_valid, Profile.build_valid] }

      subject { described_class.new(profiles) }

      it 'makes successful upload' do
        result = subject.call(client)
        body = JSON.parse(result.body)

        aggregate_failures 'success response' do
          expect(result.success?).to be_truthy
          expect(result.status).to eq(200)
          expect(body).to include('processed' => 2, 'unprocessed' => [], 'status' => 'success')
        end
      end
    end

    context 'when the gender is invalid' do
      let(:profiles) { [Profile.build_valid('Gender' => 'GG'), Profile.build_valid('Gender' => 'GG')] }
      subject { described_class.new(profiles) }

      it_behaves_like 'validation failure', 514
    end

    context 'when email is invalid' do
      let(:profiles) { [Profile.build_valid('Email' => '1234'), Profile.build_valid('Email' => '1234')] }

      subject { described_class.new(profiles) }

      it_behaves_like 'validation failure', 515
    end

    context 'when phone is invalid' do
      let(:profiles) { [Profile.build_valid('Phone' => '223'), Profile.build_valid('Phone' => '123')] }

      subject { described_class.new(profiles) }

      it_behaves_like 'validation failure', 516
    end

    context 'when employment status is invalid' do
      let(:profiles) { [Profile.build_valid('Employed' => '223'), Profile.build_valid('Employed' => '123')] }

      subject { described_class.new(profiles) }

      it_behaves_like 'validation failure', 517
    end

    context 'when education status is invalid' do
      let(:profiles) { [Profile.build_valid('Education' => '223'), Profile.build_valid('Education' => '123')] }

      subject { described_class.new(profiles) }

      it_behaves_like 'validation failure', 518
    end

    context 'when marital status is invalid' do
      let(:profiles) { [Profile.build_valid('Married' => '223'), Profile.build_valid('Married' => '123')] }

      subject { described_class.new(profiles) }

      it_behaves_like 'validation failure', 519
    end

    context 'when age is invalid' do
      let(:profiles) { [Profile.build_valid('Age' => 'aa'), Profile.build_valid('Age' => 'aa')] }

      subject { described_class.new(profiles) }

      it_behaves_like 'validation failure', 520
    end

    context 'when the identity field is missing' do
      let(:profiles) { [Profile.build_valid, Profile.build_valid] }

      subject { described_class.new(profiles, identity_field: 'fake_id') }

      it_behaves_like 'validation failure', 523
    end

    context 'when the creation date field is missing' do
      let(:profiles) { [Profile.build_valid, Profile.build_valid] }

      subject { described_class.new(profiles, date_field: 'fake_created_at') }

      it_behaves_like 'validation failure', 525
    end

    context 'with invalid credentials' do
      let(:client) { CleverTap::Client.new('fake-id', 'fake-pass') }
      subject { described_class.new([Profile.build_valid]) }

      it 'failed to upload the profiles' do
        result = subject.call(client)
        body = JSON.parse(result.body)

        aggregate_failures 'failed response' do
          expect(result.success?).to be_falsy
          expect(result.status).to eq(401)
          expect(body).to include('code' => 401,
                                  'status' => 'fail',
                                  'error' => matching(/account id/i))
        end
      end
    end
  end
end
