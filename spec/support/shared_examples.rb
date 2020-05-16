# frozen_string_literal: true

shared_examples_for "a taxt column with cleanup" do |column|
  it 'strips double spaces and colons' do
    subject.public_send "#{column}=", 'Pi   zz : : a'
    expect { subject.valid? }.to change { subject.public_send(column) }.from('Pi   zz : : a').to('Pi zz: a')
  end
end

shared_examples_for "a model that assigns `request_id` on create" do
  let!(:current_request_uuid) { SecureRandom.uuid }

  before do
    allow(RequestStore.store).to receive(:[]).with(:current_request_uuid).and_return(current_request_uuid)
  end

  it 'assigns `request_uuid`' do
    expect { instance.save! }.to change { instance.request_uuid }.
      from(nil).to(current_request_uuid)
  end
end
