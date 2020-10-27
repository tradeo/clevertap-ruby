require 'spec_helper'

RSpec.describe CleverTap::Campaign::Push do
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
        content: {
          'title' => 'Welcome',
          'body' => 'Smsbody',
          'platform_specific' =>  { # Optional
            'ios' => {
              'deep_link' => 'example.com',
              'sound_file' => 'example.caf',
              'category' => 'notification category',
              'badge_count' => 1,
              'key' => 'value_ios'
            },
            'android' => {
              'background_image' => 'http://example.jpg',
              'default_sound' => true,
              'deep_link' => 'example.com',
              'large_icon' => 'http://example.png',
              'key' => 'value_android',
              'wzrk_cid' => 'engagement'
            }
          }
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

    context 'When content does not have content' do
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

    context 'When content does not have title' do
      before do
        params[:content].delete 'title'
      end

      it 'should raise a NoContentError error' do
        expect { subject }.to raise_error(CleverTap::NoContentError)
      end
    end

    context 'success' do
      it { is_expected.to eq parsed_params }
    end

    context 'When platform_specific is sended into content (Symbol)' do
      let(:params) do
        {
          to: {
            'Email' => ['example@email.com'],
            'FBID' => ['fbidexample']
          },
          tag_group: 'mytaggroup',
          respect_frequency_caps: false,
          content: {
            'title' => 'Hi!',
            'body' => 'Smsbody',
            platform_specific: { # Optional
              'ios' => {
                'deep_link' => 'example.com',
                'sound_file' => 'example.caf',
                'category' => 'notification category',
                'badge_count' => 1,
                'key' => 'value_ios'
              }
            }
          }
        }
      end

      it 'has content and includes platform_specific' do
        expect(subject['content']).to include('platform_specific')
      end
    end

    context 'When platform_specific is sended into content' do
      let(:params) do
        {
          to: {
            'Email' => ['example@email.com'],
            'FBID' => ['fbidexample']
          },
          tag_group: 'mytaggroup',
          respect_frequency_caps: false,
          content: {
            'title' => 'Hi!',
            'body' => 'Smsbody',
            'platform_specific' => { # Optional
              'ios' => {
                'deep_link' => 'example.com',
                'sound_file' => 'example.caf',
                'category' => 'notification category',
                'badge_count' => 1,
                'key' => 'value_ios'
              }
            }
          }
        }
      end

      it 'has content and includes platform_specific' do
        expect(subject['content']).to include('platform_specific')
      end
    end

    context 'When platform_specific is sended as param' do
      let(:params) do
        {
          to: {
            'Email' => ['example@email.com'],
            'FBID' => ['fbidexample']
          },
          tag_group: 'mytaggroup',
          respect_frequency_caps: false,
          content: {
            'title' => 'Hi!',
            'body' => 'Smsbody'
          },
          platform_specific: { # Optional
            'ios' => {
              'deep_link' => 'example.com',
              'sound_file' => 'example.caf',
              'category' => 'notification category',
              'badge_count' => 1,
              'key' => 'value_ios'
            }
          }
        }
      end

      it 'has content and includes platform_specific' do
        expect(subject['content']).to include('platform_specific')
      end
    end

    context 'When platform_specific has android section, without channel' do
      let(:params) do
        {
          to: {
            'Email' => ['example@email.com'],
            'FBID' => ['fbidexample']
          },
          tag_group: 'mytaggroup',
          respect_frequency_caps: false,
          content: {
            'title' => 'Hi!',
            'body' => 'Smsbody',
            'platform_specific' =>  { # Optional
              'android' => {
                'background_image' => 'http://example.jpg',
                'default_sound' => true,
                'deep_link' => 'example.com',
                'large_icon' => 'http://example.png',
                'key' => 'value_android'
              }
            }
          }
        }
      end

      it 'should raise a NoChannelIdError error' do
        expect { subject }.to raise_error(CleverTap::NoChannelIdError)
      end
    end
  end
end
