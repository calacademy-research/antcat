require "spec_helper"

describe Names::DuplicatesWithReferences do
  let!(:first_atta_name) { create :name, name: 'Atta' }
  let!(:second_atta_name) { create :name, name: 'Atta' }

  describe "#call" do
    let!(:first_atta) { create_genus name: first_atta_name }
    let!(:second_atta) { create_genus name: second_atta_name }

    it "returns the references to the duplicate names" do
      expect(described_class.new.call).to eq(
        'Atta' => {
          first_atta_name.id => [
            { table: 'taxa', field: :name_id, id: first_atta.id },
          ],
          second_atta_name.id => [
            { table: 'taxa', field: :name_id, id: second_atta.id }
          ]
        }
      )
    end
  end

  describe "#duplicates" do
    before { create :name, name: 'Notatta' }

    it "returns the records with same name but different ID" do
      expect(described_class.new.send(:duplicates)).to match_array [first_atta_name, second_atta_name]
    end
  end
end
