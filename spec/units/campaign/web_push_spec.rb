require 'spec_helper'

RSpec.describe CleverTap::Campaign::WebPush do
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
          'title' => 'Hi!',
          'body' => 'How are you doing today?',
          'platform_specific' => { # Optional
            'safari' => {
              'deep_link' => 'https://apple.com',
              'ttl' => 10
            },
            'chrome' => {
              'image' => 'https://www.exampleImage.com',
              'icon' => 'https://www.exampleIcon.com',
              'deep_link' => ' https://google.co',
              'ttl' => 10,
              'require_interaction' => true,
              'cta_title1' => 'title',
              'cta_link1' => 'http://www.example2.com',
              'cta_iconlink1' => 'https://www.exampleIcon2.com'
            },
            'firefox' => {
              'icon' => 'https://www.exampleIcon.com',
              'deep_link' => 'https://mozilla.org',
              'ttl' => 10
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
            platform_specific:  { # Optional
              'safari' => {
                'deep_link' => 'https://apple.com',
                'ttl' => 10
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
            'platform_specific' =>  { # Optional
              'safari' => {
                'deep_link' => 'https://apple.com',
                'ttl' => 10
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
          platform_specific:  { # Optional
            'safari' => {
              'deep_link' => 'https://apple.com',
              'ttl' => 10
            }
          }
        }
      end

      it 'has content and includes platform_specific' do
        expect(subject['content']).to include('platform_specific')
      end
    end
  end
end
