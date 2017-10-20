shared_examples 'configured `Client`' do
  it 'preserves credentials in `Client`' do
    expect(subject.account_id).to eq account_id
    expect(subject.passcode).to eq account_passcode
  end
end
