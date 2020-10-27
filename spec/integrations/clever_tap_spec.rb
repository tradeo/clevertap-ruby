require 'spec_helper'

RSpec.describe CleverTap, vcr: true do
  # NOTE: clear mutations in CleverTap config
  subject(:clever_tap) { CleverTap.new(account_id: AUTH_ACCOUNT_ID, passcode: AUTH_PASSCODE) }

  describe 'uploading a profile' do
    context 'when is valid' do
      let(:profile) { Profile.build_valid }

      it 'succeed' do
        response = clever_tap.upload_profile(profile)

        aggregate_failures do
          expect(response.status).to eq('success')
          expect(response.errors).to be_empty
        end
      end
    end

    context 'when is invalid' do
      let(:profile) { Profile.build_valid('Email' => '$$$$$') }

      it 'fails' do
        response = clever_tap.upload_profile(profile)

        aggregate_failures do
          expect(response.status).to eq('fail')
          expect(response.errors).to all(be_a(Hash))
          expect(response.errors).to all(
            include('status', 'code', 'error', 'record')
          )
        end
      end
    end
  end

  describe 'uploading a many profiles' do
    context 'when only some are valid' do
      let(:valid_profile) { Profile.build_valid }
      let(:invalid_profile) { Profile.build_valid('Email' => '$$$$$') }
      let(:profiles) { [valid_profile, invalid_profile] }

      it 'partially succeds' do
        response = clever_tap.upload_profiles(profiles)

        aggregate_failures do
          expect(response.status).to eq('partial')
          expect(response.errors).to all(be_a(Hash))
          expect(response.errors).to all(
            include('status', 'code', 'error', 'record')
          )
        end
      end
    end
  end

  describe 'uploading an event' do
    subject(:clever_tap) do
      CleverTap.new(account_id: AUTH_ACCOUNT_ID, passcode: AUTH_PASSCODE, identity_field: 'ID')
    end

    context 'when is valid' do
      let(:event) do
        {
          'ID' => 555,
          'mobile' => true
        }
      end

      it 'succeed' do
        response = clever_tap.upload_event(event, name: 'register', identity_field: 'user_id')

        aggregate_failures do
          expect(response.status).to eq('success')
          expect(response.errors).to be_empty
        end
      end
    end
  end

  describe 'creating a campaign' do
    let(:campaign) do
      CleverTap::Campaign::Sms.new(
        to: { 'Email' => ['john@doe.com'] },
        content: { 'body' => 'Smsbody' }
      )
    end

    it 'succeed' do
      response = clever_tap.create_campaign(campaign)

      aggregate_failures 'success response' do
        expect(response.code).to eq(200)
      end
    end
  end
end
