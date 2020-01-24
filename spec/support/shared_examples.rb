shared_examples_for "a successful save journal operation" do
  let(:records_to_update) { [] }

  specify { expect(operation.run).to be_a_success }
  specify { expect(operation.run.context.errors).to eq [] }

  it "updates the record(s)" do
    expect { operation.run }.to_not change { records_to_update.map { |record| record&.reload } }
  end
end

shared_examples_for "an unsuccessful save journal operation" do
  let(:records_to_not_update) { [] }

  specify { expect(operation.run).to be_a_failure }

  it "returns errors" do
    expect(operation.run.context.errors.to_s).to include "Name can't be blank"
  end

  it 'does not update the record(s)' do
    expect { operation.run }.to_not change { records_to_not_update.map { |record| record&.reload } }
  end
end

shared_examples_for "a taxt column with cleanup" do |column|
  it 'strips double spaces and colons' do
    subject.public_send "#{column}=".to_sym, 'Pi   zz : : a'
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
