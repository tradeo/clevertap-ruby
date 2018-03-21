shared_examples_for 'setting allowed identities for' do |type|
  type_data = type == 'event' ? 'evtData' : 'profileData'
  described_class::ALLOWED_IDENTITIES.each do |id|
    context "when `identity` set as `#{id}` in the event" do
      let!(:params_ext) { params.merge!(identity: id) }
      let!(:data_ext) { data.merge!(id => '1414') }

      it { is_expected.to include(id => '1414') }
      it { expect(subject[type_data]).not_to include(id => '1414') }
    end
  end
end

shared_examples_for 'choosing identity for' do |type|
  evt_name = type == 'event' ? { name: 'Evt' } : {}
  before { CleverTap.setup { |c| c.identity_field = 'ID' } }
  let(:params) { { data: data }.merge!(evt_name) }
  let(:data) { { 'ID' => 1, 'Name' => 'John' } }

  context 'when custom `identity` from config' do
    it { is_expected.to include 'identity' => '1' }
  end

  context 'when `identity` different from ALLOWED_IDENTITIES and config' do
    let!(:params_ext) { params.merge!(identity: 'email') }
    let!(:data_ext) { data.merge!('email' => 'example@email.com') }

    it { is_expected.to include 'identity' => '1' }
  end

  context 'when `identity` missing from `data`' do
    let(:data) { { 'Name' => 'John' } }

    it { expect { subject }.to raise_error CleverTap::MissingIdentityError }
  end

  it_behaves_like 'setting allowed identities for', type
end

shared_examples_for 'choosing timestamp' do
  let(:data) { { 'FBID' => 1, 'Name' => 'John' } }
  let(:params) { { data: data, identity: 'FBID', name: 'evt' } }

  context 'when no `timestamp_field`' do
    it { is_expected.not_to include 'ts' }
  end

  context 'when specific `timestamp` field' do
    let!(:data_ext) { data.merge!('Open Time' => open_time) }
    let!(:params_ext) { params.merge!(timestamp_field: 'Open Time') }

    context 'and `timestamp_field` is Unix timestamp' do
      let(:open_time) { '1508241881' }
      it { is_expected.to include('ts' => open_time.to_i) }
    end

    context 'and `timestamp_field` is `DateTime` timestamp' do
      let(:open_time) { Time.now }
      it { is_expected.to include('ts' => open_time.to_i) }
    end
  end

  context 'when `custom_timestamp` specified' do
    let!(:params_ext) { params.merge!(custom_timestamp: open_time) }

    context 'and `custom_timestamp` is Unix timestamp' do
      let(:open_time) { '1508241881' }
      it { is_expected.to include('ts' => open_time.to_i) }
    end

    context 'and `custom_timestamp` is `DateTime` timestamp' do
      let(:open_time) { Time.now }
      it { is_expected.to include('ts' => open_time.to_i) }
    end
  end
end

shared_examples_for 'proper type' do
  let(:data) { { 'FBID' => '1414', 'Name' => 'John' } }
  let(:params) { { data: data, name: 'e', identity: 'FBID' } }

  it { is_expected.to include described_class::TYPE_KEY_STRING => described_class::TYPE_VALUE_STRING }
end

shared_examples_for 'constructing data for' do |type|
  obj_type = type == 'event' ? 'evtData' : 'profileData'
  evt_name = type == 'event' ? { name: 'Evt' } : {}

  let(:data) { { 'FBID' => '1414', 'Name' => 'John' } }
  let(:params) { { data: data, identity: 'FBID' }.merge!(evt_name) }

  context 'when no `data` param in `params` hash' do
    let(:params) { {}.merge!(evt_name) }
    it { expect { subject }.to raise_error CleverTap::NoDataError }
  end

  context 'when `data` empty hash in `params` hash' do
    let(:params) { { data: {} }.merge!(evt_name) }
    it { expect { subject }.to raise_error CleverTap::NoDataError }
  end

  context 'when `data` available in `params` hash' do
    it { is_expected.to include(obj_type => { 'Name' => 'John' }) }
  end
end
