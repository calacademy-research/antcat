require 'spec_helper'

describe SpeciesName do
  # Changing the genus of a species name
  describe "#change_parent" do
    it "replaces the genus part of the name" do
      species_name = SpeciesName.new(
        name: 'Atta major',
        name_html: '<i>Atta major</i>',
        epithet: 'major',
        epithet_html: '<i>major</i>')

      genus_name = GenusName.new(
        name: 'Eciton',
        name_html: '<i>Eciton</i>',
        epithet: 'niger',
        epithet_html: '<i>niger</i>')

      species_name.change_parent genus_name
      expect(species_name.name).to eq 'Eciton major'
      expect(species_name.name_html).to eq '<i>Eciton major</i>'
      expect(species_name.epithet).to eq 'major'
      expect(species_name.epithet_html).to eq '<i>major</i>'
    end

    context "name already exists" do
      context "name is used by a different taxon" do
        it "raises" do
          existing_species_name = SpeciesName.create! name: 'Eciton major', epithet: 'major'
          species = create_species 'Eciton major', name: existing_species_name

          species_name = SpeciesName.create! name: 'Atta major', epithet: 'major'
          genus_name = GenusName.create! name: 'Eciton', epithet: 'Eciton'
          protonym_name = GenusName.create! name: 'Eciton', epithet: 'Eciton'

          expect { species_name.change_parent genus_name }.to raise_error
        end
      end

      context "name is an orphan" do
        it "doesn't raise" do
          orphan_species_name = SpeciesName.create! name: 'Eciton minor', epithet: 'minor'
          species_name = SpeciesName.create! name: 'Atta minor', epithet: 'minor'
          genus_name = GenusName.create! name: 'Eciton', epithet: 'Eciton'
          protonym_name = GenusName.create! name: 'Eciton', epithet: 'Eciton'

          expect { species_name.change_parent genus_name }.not_to raise_error
        end
      end
    end
  end
end
