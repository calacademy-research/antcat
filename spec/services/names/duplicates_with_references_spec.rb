require "spec_helper"

describe Names::DuplicatesWithReferences do
  let!(:first_atta_name) { create :name, name: 'Atta' }
  let!(:second_atta_name) { create :name, name: 'Atta' }

  describe "#call" do
    let!(:first_atta) { create :genus, name: first_atta_name }
    let!(:second_atta) { create :genus, name: second_atta_name }

    it "returns the references to the duplicate names" do
      expect(described_class[]).to eq(
        'Atta' => {
          first_atta_name.id => [
            { table: 'taxa', field: :name_id, id: first_atta.id }
          ],
          second_atta_name.id => [
            { table: 'taxa', field: :name_id, id: second_atta.id }
          ]
        }
      )
    end
  end
end
