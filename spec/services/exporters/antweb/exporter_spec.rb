# TODO too much untested stubs. Some specs here have no idea if they are broken.

require 'spec_helper'

describe Exporters::Antweb::Exporter do
  subject(:exporter) { described_class.new }

  before { allow(exporter).to receive(:export_history).and_return 'history' }

  def export_taxon taxon
    exporter.send :export_taxon, taxon
  end

  describe "#export_taxon" do
    # "allow_author_last_names_string_for_and_return"
    def allow_ALNS_for taxon, value
      allow(exporter).to receive(:author_last_names_string).with(taxon).and_return value
    end

    def allow_year_for taxon, value
      allow(exporter).to receive(:year).with(taxon).and_return value
    end

    let(:ponerinae) { create_subfamily 'Ponerinae' }
    let(:attini) { create_tribe 'Attini', subfamily: ponerinae }

    before do
      allow_any_instance_of(described_class).to receive(:authorship_html_string)
        .and_return '<span title="Bolton. Ants>Bolton, 1970</span>'
    end

    it "can export a subfamily" do
      create_genus subfamily: ponerinae, tribe: nil

      allow(ponerinae).to receive(:authorship_string).and_return 'Bolton, 2011'
      allow_ALNS_for ponerinae, 'Bolton'
      allow_year_for ponerinae, 2001

      expect(export_taxon(ponerinae)[0..17]).to eq [
        ponerinae.id, 'Ponerinae', nil, nil, nil, nil, nil,
        'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>',
        'Bolton', '2001', 'valid', 'TRUE', nil, 'FALSE', nil, 'FALSE', 'history'
      ]
    end

    it "can export fossil taxa" do
      create_genus subfamily: ponerinae, tribe: nil
      fossil = create_genus 'Atta', subfamily: ponerinae, tribe: nil, fossil: true

      allow(fossil).to receive(:authorship_string).and_return 'Fisher, 2013'
      allow_ALNS_for fossil, 'Fisher'
      allow_year_for fossil, 2001

      expect(export_taxon(fossil)[0..17]).to eq [
        fossil.id, 'Ponerinae', nil, 'Atta', nil, nil, nil,
        'Fisher, 2013', '<span title="Bolton. Ants>Bolton, 1970</span>',
        'Fisher', '2001', 'valid', 'TRUE', nil, 'FALSE', nil, 'TRUE', 'history'
      ]
    end

    it "can export a genus" do
      dacetini = create_tribe 'Dacetini', subfamily: ponerinae
      acanthognathus = create_genus 'Acanothognathus', subfamily: ponerinae, tribe: dacetini

      allow(acanthognathus).to receive(:authorship_string).and_return 'Bolton, 2011'
      allow_ALNS_for acanthognathus, 'Bolton'
      allow_year_for acanthognathus, 2001

      expect(export_taxon(acanthognathus)[0..17]).to eq [
        acanthognathus.id, 'Ponerinae', 'Dacetini', 'Acanothognathus', nil, nil, nil,
        'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>',
        'Bolton', '2001', 'valid', 'TRUE', nil, 'FALSE', nil, 'FALSE', 'history'
      ]
    end

    it "can export a genus without a tribe" do
      acanthognathus = create_genus 'Acanothognathus', subfamily: ponerinae, tribe: nil

      allow(acanthognathus).to receive(:authorship_string).and_return 'Bolton, 2011'
      allow_ALNS_for acanthognathus, 'Bolton'
      allow_year_for acanthognathus, 2001

      expect(export_taxon(acanthognathus)[0..17]).to eq [
        acanthognathus.id, 'Ponerinae', nil, 'Acanothognathus', nil, nil, nil,
        'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>',
        'Bolton', '2001', 'valid', 'TRUE', nil, 'FALSE', nil, 'FALSE', 'history'
      ]
    end

    it "can export a genus without a subfamily as being in 'incertae_sedis'" do
      acanthognathus = create_genus 'Acanothognathus', tribe: nil, subfamily: nil

      allow(acanthognathus).to receive(:authorship_string).and_return 'Fisher, 2013'
      allow_ALNS_for acanthognathus, 'Fisher'
      allow_year_for acanthognathus, 2001

      expect(export_taxon(acanthognathus)[0..17]).to eq [
        acanthognathus.id, 'incertae_sedis', nil, 'Acanothognathus', nil, nil, nil,
        'Fisher, 2013', '<span title="Bolton. Ants>Bolton, 1970</span>',
        'Fisher', '2001', 'valid', 'TRUE', nil, 'FALSE', nil, 'FALSE', 'history'
      ]
    end

    describe "Exporting species" do
      it "exports one correctly" do
        atta = create_genus 'Atta', tribe: attini
        species = create_species 'Atta robustus', genus: atta

        allow(species).to receive(:authorship_string).and_return 'Bolton, 2011'
        allow_ALNS_for species, 'Bolton'
        allow_year_for species, 2001

        expect(export_taxon(species)[0..17]).to eq [
          species.id, 'Ponerinae', 'Attini', 'Atta', nil, 'robustus', nil,
          'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>',
          'Bolton', '2001', 'valid', 'TRUE', nil, 'FALSE', nil, 'FALSE', 'history'
        ]
      end

      it "can export a species without a tribe" do
        atta = create_genus 'Atta', subfamily: ponerinae, tribe: nil
        species = create_species 'Atta robustus', genus: atta

        allow(species).to receive(:authorship_string).and_return 'Bolton, 2011'
        allow_ALNS_for species, 'Bolton'
        allow_year_for species, 2001

        expect(export_taxon(species)[0..17]).to eq [
          species.id, 'Ponerinae', nil, 'Atta', nil, 'robustus', nil,
          'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>',
          'Bolton', '2001', 'valid', 'TRUE', nil, 'FALSE', nil, 'FALSE', 'history'
        ]
      end

      it "exports a species without a subfamily as being in the 'incertae sedis' subfamily" do
        atta = create_genus 'Atta', subfamily: nil, tribe: nil
        species = create_species 'Atta robustus', genus: atta

        allow(species).to receive(:authorship_string).and_return 'Bolton, 2011'
        allow_ALNS_for species, 'Bolton'
        allow_year_for species, 2001

        expect(export_taxon(species)[0..17]).to eq [
          species.id, 'incertae_sedis', nil, 'Atta', nil, 'robustus', nil,
          'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>',
          'Bolton', '2001', 'valid', 'TRUE', nil, 'FALSE', nil, 'FALSE', 'history'
        ]
      end
    end

    describe "Exporting subspecies" do
      it "exports one correctly" do
        atta = create_genus 'Atta', subfamily: ponerinae, tribe: attini
        species = create_species 'Atta robustus', subfamily: ponerinae, genus: atta
        subspecies = create_subspecies 'Atta robustus emeryii', subfamily: ponerinae, genus: atta, species: species

        allow(subspecies).to receive(:authorship_string).and_return 'Bolton, 2011'
        allow_ALNS_for subspecies, 'Bolton'
        allow_year_for subspecies, 2001

        expect(export_taxon(subspecies)[0..17]).to eq [
          subspecies.id, 'Ponerinae', 'Attini', 'Atta', nil, 'robustus', 'emeryii',
          'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>',
          'Bolton', '2001', 'valid', 'TRUE', nil, 'FALSE', nil, 'FALSE', 'history'
        ]
      end

      it "can export a subspecies without a tribe" do
        atta = create_genus 'Atta', subfamily: ponerinae, tribe: nil
        species = create_species 'Atta robustus', subfamily: ponerinae, genus: atta
        subspecies = create_subspecies 'Atta robustus emeryii', genus: atta, species: species

        allow(subspecies).to receive(:authorship_string).and_return 'Bolton, 2011'
        allow_ALNS_for subspecies, 'Bolton'
        allow_year_for subspecies, 2001

        expect(export_taxon(subspecies)[0..17]).to eq [
          subspecies.id, 'Ponerinae', nil, 'Atta', nil, 'robustus', 'emeryii',
          'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>',
          'Bolton', '2001', 'valid', 'TRUE', nil, 'FALSE', nil, 'FALSE', 'history'
        ]
      end

      it "exports a subspecies without a subfamily as being in the 'incertae sedis' subfamily" do
        atta = create_genus 'Atta', subfamily: nil, tribe: nil
        species = create_species 'Atta robustus', subfamily: nil, genus: atta
        subspecies = create_subspecies 'Atta robustus emeryii', subfamily: nil, genus: atta, species: species

        allow(subspecies).to receive(:authorship_string).and_return 'Bolton, 2011'
        allow_ALNS_for subspecies, 'Bolton'
        allow_year_for subspecies, 2001

        expect(export_taxon(subspecies)[0..17]).to eq [
          subspecies.id, 'incertae_sedis', nil, 'Atta', nil, 'robustus', 'emeryii',
          'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>',
          'Bolton', '2001', 'valid', 'TRUE', nil, 'FALSE', nil, 'FALSE', 'history'
        ]
      end
    end
  end

  describe "Current valid name" do
    let(:taxon) { create_genus }

    it "exports the current valid name of the taxon" do
      old = create_genus
      taxon.update! current_valid_taxon_id: old.id
      expect(export_taxon(taxon)[13]).to end_with old.name.name
    end

    it "looks at synonyms if there isn't a current_valid_taxon" do
      senior_synonym = create_species 'Eciton major', genus: taxon
      junior_synonym = create_species 'Atta major', genus: taxon, status: 'synonym'
      Synonym.create! junior_synonym: junior_synonym, senior_synonym: senior_synonym
      expect(export_taxon(junior_synonym)[13]).to end_with 'Eciton major'
    end

    it "returns nil if the taxon itself is valid" do
      expect(export_taxon(taxon)[13]).to be_nil
    end
  end

  describe "Sending all taxa - not just valid" do
    it "can export a junior synonym" do
      taxon = create_genus status: 'original combination'
      expect(export_taxon(taxon)[11]).to eq 'original combination'
    end

    it "can export a Tribe" do
      taxon = create_tribe
      expect(export_taxon(taxon)).not_to be_nil
    end

    it "can export a Subgenus" do
      taxon = create_subgenus 'Atta (Boyo)'
      expect(export_taxon(taxon)[4]).to eq 'Boyo'
    end
  end

  describe "Sending 'was original combination' so that AntWeb knows when to use parentheses around authorship" do
    it "sends TRUE or FALSE" do
      taxon = create_genus status: 'original combination'
      expect(export_taxon(taxon)[14]).to eq 'TRUE'
    end

    it "sends TRUE or FALSE" do
      taxon = create_genus
      expect(export_taxon(taxon)[14]).to eq 'FALSE'
    end
  end

  describe "Sending 'author_date_html' that includes the full reference in the rollover" do
    let(:taxon) { create_genus }

    before do
      reference = create :article_reference,
        author_names: [create(:author_name, name: "Forel, A.")],
        citation_year: "1874",
        title: "Les fourmis de la Suisse",
        journal: create(:journal, name: "Neue Denkschriften"),
        series_volume_issue: "26",
        pagination: "1-452"
      taxon.protonym.authorship.update! reference: reference
    end

    specify do
      expect(export_taxon(taxon)[8])
        .to eq '<span title="Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.">Forel, 1874</span>'
    end
  end

  describe "Original combination" do
    let(:original_combination) { create_species 'Atta major' }
    let(:recombination) { create_species 'Eciton major' }

    before do
      original_combination.status = 'original combination'
      original_combination.current_valid_taxon = recombination
      recombination.protonym.name = original_combination.name
      original_combination.save!
      recombination.save!
    end

    it "is the protonym, otherwise" do
      expect(export_taxon(recombination)[15]).to eq original_combination.name.name
    end
  end

  describe "Reference ID" do
    let!(:taxon) { create_genus }

    it "sends the protonym's reference ID" do
      reference_id = export_taxon(taxon)[18]
      expect(reference_id).to eq taxon.protonym.authorship.reference.id
    end

    it "sends nil if the protonym's reference is a MissingReference" do
      taxon.protonym.authorship.reference = create :missing_reference
      taxon.save!
      reference_id = export_taxon(taxon)[18]
      expect(reference_id).to be_nil
    end
  end

  describe "Sending other fields to AntWeb" do
    it "sends the biogeographic region" do
      taxon = create_genus biogeographic_region: 'Neotropic'
      expect(export_taxon(taxon)[19]).to eq 'Neotropic'
    end

    it "sends the locality" do
      taxon = create_genus protonym: create(:protonym, locality: 'Canada')
      expect(export_taxon(taxon)[20]).to eq 'Canada'
    end
  end

  describe "Current valid rank" do
    it "sends the right value for each class" do
      expect(export_taxon(create_subfamily)[21]).to eq 'Subfamily'
      expect(export_taxon(create_genus)[21]).to eq 'Genus'
      expect(export_taxon(create_subgenus)[21]).to eq 'Subgenus'
      expect(export_taxon(create_species)[21]).to eq 'Species'
      expect(export_taxon(create_subspecies)[21]).to eq 'Subspecies'
    end
  end

  describe "Current valid parent" do
    let(:subfamily) { create_subfamily 'Dolichoderinae' }
    let(:tribe) { create_tribe 'Attini', subfamily: subfamily }
    let(:genus) { create_genus 'Atta', tribe: tribe, subfamily: subfamily }
    let(:subgenus) { create_subgenus genus: genus, tribe: tribe, subfamily: subfamily }
    let(:species) { create_species 'Atta betta', genus: genus, subfamily: subfamily }

    it "sdoesn't punt on a subfamily's family" do
      taxon = create_subfamily
      expect(export_taxon(taxon)[23]).to eq 'Formicidae'
    end

    it "handles a taxon's subfamily" do
      taxon = create_tribe subfamily: subfamily
      expect(export_taxon(taxon)[23]).to eq 'Dolichoderinae'
    end

    it "doesn't skip over tribe and return the subfamily" do
      taxon = create_genus tribe: tribe
      expect(export_taxon(taxon)[23]).to eq 'Attini'
    end

    it "returns the subfamily only if there's no tribe" do
      taxon = create_genus subfamily: subfamily, tribe: nil
      expect(export_taxon(taxon)[23]).to eq 'Dolichoderinae'
    end

    it "skips over subgenus and return the genus", pending: true do
      skip "the subgenus factory is broken"

      taxon = create_species genus: genus, subgenus: subgenus
      expect(export_taxon(taxon)[23]).to eq 'Atta'
    end

    it "handles a taxon's species" do
      taxon = create_subspecies 'Atta betta cappa', species: species, genus: genus, subfamily: subfamily
      expect(export_taxon(taxon)[23]).to eq 'Atta betta'
    end

    it "handles a synonym" do
      senior = create_genus 'Eciton', subfamily: subfamily
      junior = create_genus 'Atta', subfamily: subfamily, current_valid_taxon: senior
      taxon = create_species genus: junior
      Synonym.create! senior_synonym: senior, junior_synonym: junior

      expect(export_taxon(taxon)[23]).to eq 'Eciton'
    end

    it "handles a genus without a subfamily" do
      taxon = create_genus 'Acanothognathus', tribe: nil, subfamily: nil
      expect(export_taxon(taxon)[23]).to eq 'Formicidae'
    end

    it "handles a subspecies without a species" do
      taxon = create_subspecies 'Atta betta kappa', genus: genus, species: nil, subfamily: nil
      expect(export_taxon(taxon)[23]).to eq 'Atta'
    end
  end

  describe "Test stubbed" do
    let(:ponerinae) { create_subfamily "Ponerinae" }

    it "'author date html' # [8]" do
      reference = ponerinae.protonym.authorship.reference
      author = reference.principal_author_last_name_cache
      year = reference.citation_year
      title = reference.title
      journal_name = reference.journal.name
      pagination = reference.pagination
      volume = reference.series_volume_issue

      expected = %Q[<span title="#{author}, B.L. #{year}. #{title}. #{journal_name} #{pagination}:#{volume}.">#{author}, #{year}</span>]
      expect(export_taxon(ponerinae)[8]).to eq expected
    end
  end
end
