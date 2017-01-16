require 'spec_helper'

describe Name do
  it { should be_versioned }
  it { should validate_presence_of :name }

  describe "#epithet_with_fossil_html" do
    it "formats the fossil symbol" do
      expect(SpeciesName.new(epithet_html: '<i>major</i>').epithet_with_fossil_html(true)).to eq '<i>&dagger;</i><i>major</i>'
      expect(SpeciesName.new(epithet_html: '<i>major</i>').epithet_with_fossil_html(false)).to eq '<i>major</i>'
      expect(GenusName.new(epithet_html: '<i>Atta</i>').epithet_with_fossil_html(true)).to eq '<i>&dagger;</i><i>Atta</i>'
      expect(GenusName.new(epithet_html: '<i>Atta</i>').epithet_with_fossil_html(false)).to eq '<i>Atta</i>'
      expect(SubfamilyName.new(epithet_html: 'Attanae').epithet_with_fossil_html(true)).to eq '&dagger;Attanae'
      expect(SubfamilyName.new(epithet_html: 'Attanae').epithet_with_fossil_html(false)).to eq 'Attanae'
    end
  end

  describe "#to_html_with_fossil" do
    it "formats the fossil symbol" do
      expect(SpeciesName.new(name_html: '<i>Atta major</i>').to_html_with_fossil(false)).to eq '<i>Atta major</i>'
      expect(SpeciesName.new(name_html: '<i>Atta major</i>').to_html_with_fossil(true)).to eq '<i>&dagger;</i><i>Atta major</i>'
    end
  end

  describe "#set_taxon_caches" do
    before do
      @atta = find_or_create_name 'Atta'
      @atta.update_attribute :name_html, '<i>Atta</i>'
    end

    it "sets the name_cache and name_html_cache in the taxon when assigned" do
      taxon = create_genus 'Eciton'
      expect(taxon.name_cache).to eq 'Eciton'
      expect(taxon.name_html_cache).to eq '<i>Eciton</i>'

      taxon.name = @atta
      taxon.save!
      expect(taxon.name_cache).to eq 'Atta'
      expect(taxon.name_html_cache).to eq '<i>Atta</i>'
    end

    it "changes the cache when the contents of the name change" do
      taxon = create_genus name: @atta
      expect(taxon.name_cache).to eq 'Atta'
      expect(taxon.name_html_cache).to eq '<i>Atta</i>'
      @atta.update name: 'Betta', name_html: '<i>Betta</i>'
      taxon.reload
      expect(taxon.name_cache).to eq 'Betta'
      expect(taxon.name_html_cache).to eq '<i>Betta</i>'
    end

    it "changes the cache when a different name is assigned" do
      betta = find_or_create_name 'Betta'
      betta.update_attribute :name_html, '<i>Betta</i>'

      taxon = create_genus name: @atta
      taxon.update_attribute :name, betta
      expect(taxon.name_cache).to eq 'Betta'
      expect(taxon.name_html_cache).to eq '<i>Betta</i>'
    end
  end

  describe ".duplicates" do
    it "returns the records with same name but different ID" do
      first_atta_name = create :name, name: 'Atta'
      second_atta_name = create :name, name: 'Atta'
      create :name, name: 'Notatta'

      expect(Name.duplicates).to match_array [first_atta_name, second_atta_name]
    end
  end

  describe ".duplicates_with_references" do
    it "returns the references to the duplicate names" do
      first_atta_name = create :name, name: 'Atta'
      first_atta = create_genus name: first_atta_name
      second_atta_name = create :name, name: 'Atta'
      second_atta = create_genus name: second_atta_name

      results = Name.duplicates_with_references
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

  describe "#references" do
    it "returns references in fields" do
      atta = create_genus 'Atta'
      protonym = create :protonym, name: atta.name
      atta.update_attribute :protonym, protonym
      atta.update_attribute :type_name, atta.name

      expect(atta.name.references).to match_array [
        { table: 'taxa', field: :name_id, id: atta.id },
        { table: 'taxa', field: :type_name_id, id: atta.id },
        { table: 'protonyms', field: :name_id, id: protonym.id }
      ]
    end

    it "returns references in taxt" do
      atta = create_genus 'Atta'
      eciton = create_genus 'Eciton'
      eciton.update_attribute :type_taxt, "{nam #{atta.name.id}}"
      expect(atta.name.references).to match_array [
        { table: 'taxa', field: :name_id, id: atta.id },
        { table: 'taxa', field: :type_taxt, id: eciton.id }
      ]
    end
  end

  describe "#references_in_taxt" do
    it "returns instances that reference this name" do
      name = Name.create! name: 'Atta'

      # Create an instance for each type of taxt.
      Taxt::TAXT_FIELDS.each do |klass, fields|
        fields.each { |field| create klass, field => "{nam #{name.id}}" }
      end

      # Count the total referencing items.
      refs = name.send :references_in_taxt
      expect(refs.length).to eq(
        Taxt::TAXT_FIELDS.map { |klass, fields| fields.length }.reduce(&:+)
      )

      # Count the total referencing items of each type.
      Taxt::TAXT_FIELDS.each do |klass, fields|
        fields.each do |field|
          expect(refs.select { |i| i[:table] == klass.table_name }.length).to eq(
            Taxt::TAXT_FIELDS.detect { |k, f| k == klass }[1].length
          )
        end
      end
    end
  end

  describe "#quadrinomial?" do
    it "just considers quadrinomials quadrinomials - nothing else" do
      name = SubfamilyName.new name: 'Acidinae', epithet: 'Acidinae', epithets: nil
      expect(name).not_to be_quadrinomial

      name = TribeName.new name: 'Acidini', epithet: 'Acidini', epithets: nil
      expect(name).not_to be_quadrinomial

      name = GenusName.new name: 'Acus', epithet: 'Acus', epithets: nil
      expect(name).not_to be_quadrinomial

      name = SubgenusName.new name: 'Acus (Rex)', epithet: 'Rex', epithets: nil
      expect(name).not_to be_quadrinomial

      name = SpeciesName.new name: 'Acus major', epithet: 'major', epithets: 'major'
      expect(name).not_to be_quadrinomial

      name = SubspeciesName.new name: 'Acus major minor',
        epithet: 'major minor', epithets: 'major minor'
      expect(name).not_to be_quadrinomial

      name = SubspeciesName.new name: 'Acus major minor medium',
        epithet: 'medium', epithets: 'major minor medium'
      expect(name).to be_quadrinomial
    end
  end

  describe ".find_by_name" do
    it "prioritizes names already associated with taxa" do
      atta_name = create :name, name: 'Atta'
      taxon = create_genus 'Atta'

      expect(taxon.name).not_to eq atta_name
      expect(Name.find_by_name('Atta')).to eq taxon.name
    end
  end
end
