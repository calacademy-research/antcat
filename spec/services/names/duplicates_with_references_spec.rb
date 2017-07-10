require "spec_helper"

describe Names::DuplicatesWithReferences do
  describe "#call" do
    it "returns the references to the duplicate names" do
      first_atta_name = create :name, name: 'Atta'
      first_atta = create_genus name: first_atta_name
      second_atta_name = create :name, name: 'Atta'
      second_atta = create_genus name: second_atta_name

      results = described_class.new.call
      expect(results).to eq(
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
    it "returns the records with same name but different ID" do
      first_atta_name = create :name, name: 'Atta'
      second_atta_name = create :name, name: 'Atta'
      create :name, name: 'Notatta'

      expect(described_class.new.send(:duplicates)).to match_array [first_atta_name, second_atta_name]
    end
  end
end
