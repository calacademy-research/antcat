require 'spec_helper'

describe SubspeciesName do

  describe "Name parts" do
    it "should know its species epithet" do
      name = SubspeciesName.new name: 'Atta major minor', epithet: 'minor', epithets: 'major minor'
      expect(name.genus_epithet).to eq('Atta')
      expect(name.species_epithet).to eq('major')
      expect(name.subspecies_epithets).to eq('minor')
    end
  end

  describe "Changing the species of a subspecies name" do
    it "should replace the species part of the name and fix all the other parts, too" do
      subspecies_name = SubspeciesName.new(
        name: 'Atta major minor',
        name_html: '<i>Atta major minor</i>',
        epithet: 'minor',
        epithet_html: '<i>minor</i>',
        epithets: 'major minor')

      species_name = SpeciesName.new(
        name: 'Eciton niger',
        name_html: '<i>Eciton niger</i>',
        epithet: 'niger',
        epithet_html: '<i>niger</i>')

      subspecies_name.change_parent species_name

      expect(subspecies_name.name).to eq('Eciton niger minor')
      expect(subspecies_name.name_html).to eq('<i>Eciton niger minor</i>')
      expect(subspecies_name.epithet).to eq('minor')
      expect(subspecies_name.epithet_html).to eq('<i>minor</i>')
      expect(subspecies_name.epithets).to eq('niger minor')
    end
    it "should handle more than one subspecies epithet" do
      subspecies_name = SubspeciesName.new(
        name: 'Atta major minor medii',
        name_html: '<i>Atta major minor medii</i>',
        epithet: 'medii',
        epithet_html: '<i>medii</i>',
        epithets: 'major minor medii')

      species_name = SpeciesName.new(
        name: 'Eciton niger',
        name_html: '<i>Eciton niger</i>',
        epithet: 'niger',
        epithet_html: '<i>niger</i>')

      subspecies_name.change_parent species_name

      expect(subspecies_name.name).to eq('Eciton niger minor medii')

      expect(subspecies_name.name_html).to eq('<i>Eciton niger minor medii</i>')
      expect(subspecies_name.epithet).to eq('medii')
      expect(subspecies_name.epithet_html).to eq('<i>medii</i>')
      expect(subspecies_name.epithets).to eq('niger minor medii')
    end
    it "should raise an error if the new name already exists for a different taxon" do
      existing_subspecies_name = SubspeciesName.create! name: 'Eciton niger minor', epithet: 'minor', epithets: 'niger minor'
      subspecies = create_subspecies 'Eciton niger minor', name: existing_subspecies_name
      subspecies_name = SubspeciesName.create! name: 'Atta major minor', epithet: 'minor', epithets: 'major minor'
      species_name = SpeciesName.create! name: 'Eciton niger', epithet: 'niger'
      protonym_name = SpeciesName.create! name: 'Eciton niger', epithet: 'niger'

      expect {subspecies_name.change_parent species_name}.to raise_error
    end
    it "should not raise an error if the new name already exists, but is an orphan" do
      orphan_subspecies_name = SubspeciesName.create! name: 'Eciton niger minor', epithet: 'minor', epithets: 'niger minor'
      subspecies_name = SubspeciesName.create! name: 'Atta major minor', epithet: 'minor', epithets: 'major minor'
      species_name = SpeciesName.create! name: 'Eciton niger', epithet: 'niger'
      protonym_name = SpeciesName.create! name: 'Eciton niger', epithet: 'niger'
      expect {subspecies_name.change_parent species_name}.not_to raise_error
    end
  end

   describe "Subspecies epithets" do
    it "should return the subspecies epithets minus the species epithet" do
      name = SubspeciesName.new name: 'Acus major minor medium', name_html: '<i>Acus major minor medium</i>', epithet: 'medium',
        epithet_html: '<i>medium</i>', epithets: 'major minor medium', protonym_html: '<i>Acus major minor medium</i>'
      expect(name.subspecies_epithets).to eq('minor medium')
    end
  end

end