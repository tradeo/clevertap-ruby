require 'spec_helper'

RSpec.describe 'Clever Tap integration', vcr: true do
  # NOTE: clear mutations in CleverTap config
  subject(:clever_tap) do
    CleverTap.new(account_id: AUTH_ACCOUNT_ID, passcode: AUTH_PASSCODE) do |config|
      config.profile_identity_field = 'id'
    end
  end

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

      it 'fail' do
        response = clever_tap.upload_profile(profile)

        aggregate_failures do
          expect(response.status).to eq('fail')
          expect(response.errors.tap { |a, *_| a.delete('error') }).to contain_exactly(
            a_hash_including('status' => 'fail', 'record' => a_hash_including('identity' => profile['id'].to_s))
          )
        end
      end
    end
  end

  describe 'uploading many profiles' do
    context 'when only some are valid' do
      let(:profiles) { [Profile.build_valid, Profile.new] }

      it 'partial succeed' do
        response = clever_tap.upload_profiles(profiles)

        aggregate_failures do
          expect(response.status).to eq('partial')
          expect(response.errors).to contain_exactly(
            a_hash_including(
              'status' => 'fail',
              'record' => a_hash_including('identity' => '', 'profileData' => {})
            )
          )
        end
      end
    end
  end

  describe 'uploading an event' do
    context 'when is valid' do
      let(:event) do
        {
          'user_id' => 555,
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

    context 'when is invalid' do
      context 'with missing identity field' do
        subject(:clever_tap) do
          CleverTap.new(account_id: AUTH_ACCOUNT_ID, passcode: AUTH_PASSCODE) do |config|
            config.event_identity_field = 'User ID'
            config.event_identity_field_for 'register', 'ID'
          end
        end

        let(:event) do
          {
            'User ID' => 555,
            'mobile' => true
          }
        end

        it do
          response = clever_tap.upload_event(event, name: 'register')

          aggregate_failures do
            expect(response.status).to eq('fail')
            expect(response.errors).not_to be_empty
          end
        end
      end
    end
  end
end
