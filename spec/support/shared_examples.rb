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
