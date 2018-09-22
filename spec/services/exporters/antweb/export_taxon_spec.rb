# TODO too much untested stubs. Some specs here have no idea if they are broken.

require 'spec_helper'

# rubocop:disable RSpec/SubjectStub
describe Exporters::Antweb::ExportTaxon do
  subject(:exporter) { described_class.new }

  def export_taxon taxon
    exporter.call(taxon)
  end

  describe "#call" do
    # "allow_author_last_names_string_for_and_return"
    def allow_alns_for taxon, value
      allow(exporter).to receive(:author_last_names_string).with(taxon).and_return value
    end

    def allow_year_for taxon, value
      allow(exporter).to receive(:year).with(taxon).and_return value
    end

    let(:ponerinae) { create_subfamily 'Ponerinae' }
    let(:attini) { create_tribe 'Attini', subfamily: ponerinae }
    let(:taxon) { create :family }

    before do
      allow_any_instance_of(described_class).to receive(:authorship_html_string).
        and_return '<span title="Bolton. Ants>Bolton, 1970</span>'
    end

    describe "[0]: `antcat_id`" do
      specify { expect(export_taxon(taxon)[0]).to eq taxon.id }
    end

    it "can export a subfamily" do
      create_genus subfamily: ponerinae, tribe: nil

      allow(ponerinae).to receive(:author_citation).and_return 'Bolton, 2011'
      allow_alns_for ponerinae, 'Bolton'
      allow_year_for ponerinae, 2001

      expect(export_taxon(ponerinae)[1..16]).to eq [
        'Ponerinae', nil, nil, nil, nil, nil,
        'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>',
        'Bolton', '2001', 'valid', 'TRUE', nil, 'FALSE', nil, 'FALSE'
      ]
    end

    it "can export fossil taxa" do
      create_genus subfamily: ponerinae, tribe: nil
      fossil = create_genus 'Atta', subfamily: ponerinae, tribe: nil, fossil: true

      allow(fossil).to receive(:author_citation).and_return 'Fisher, 2013'
      allow_alns_for fossil, 'Fisher'
      allow_year_for fossil, 2001

      expect(export_taxon(fossil)[1..16]).to eq [
        'Ponerinae', nil, 'Atta', nil, nil, nil,
        'Fisher, 2013', '<span title="Bolton. Ants>Bolton, 1970</span>',
        'Fisher', '2001', 'valid', 'TRUE', nil, 'FALSE', nil, 'TRUE'
      ]
    end

    it "can export a genus" do
      dacetini = create_tribe 'Dacetini', subfamily: ponerinae
      acanthognathus = create_genus 'Acanothognathus', subfamily: ponerinae, tribe: dacetini

      allow(acanthognathus).to receive(:author_citation).and_return 'Bolton, 2011'
      allow_alns_for acanthognathus, 'Bolton'
      allow_year_for acanthognathus, 2001

      expect(export_taxon(acanthognathus)[1..16]).to eq [
        'Ponerinae', 'Dacetini', 'Acanothognathus', nil, nil, nil,
        'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>',
        'Bolton', '2001', 'valid', 'TRUE', nil, 'FALSE', nil, 'FALSE'
      ]
    end

    it "can export a genus without a tribe" do
      acanthognathus = create_genus 'Acanothognathus', subfamily: ponerinae, tribe: nil

      allow(acanthognathus).to receive(:author_citation).and_return 'Bolton, 2011'
      allow_alns_for acanthognathus, 'Bolton'
      allow_year_for acanthognathus, 2001

      expect(export_taxon(acanthognathus)[1..16]).to eq [
        'Ponerinae', nil, 'Acanothognathus', nil, nil, nil,
        'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>',
        'Bolton', '2001', 'valid', 'TRUE', nil, 'FALSE', nil, 'FALSE'
      ]
    end

    it "can export a genus without a subfamily as being in 'incertae_sedis'" do
      acanthognathus = create_genus 'Acanothognathus', tribe: nil, subfamily: nil

      allow(acanthognathus).to receive(:author_citation).and_return 'Fisher, 2013'
      allow_alns_for acanthognathus, 'Fisher'
      allow_year_for acanthognathus, 2001

      expect(export_taxon(acanthognathus)[1..16]).to eq [
        'incertae_sedis', nil, 'Acanothognathus', nil, nil, nil,
        'Fisher, 2013', '<span title="Bolton. Ants>Bolton, 1970</span>',
        'Fisher', '2001', 'valid', 'TRUE', nil, 'FALSE', nil, 'FALSE'
      ]
    end

    describe "Exporting species" do
      it "exports one correctly" do
        atta = create_genus 'Atta', tribe: attini
        species = create_species 'Atta robustus', genus: atta

        allow(species).to receive(:author_citation).and_return 'Bolton, 2011'
        allow_alns_for species, 'Bolton'
        allow_year_for species, 2001

        expect(export_taxon(species)[1..16]).to eq [
          'Ponerinae', 'Attini', 'Atta', nil, 'robustus', nil,
          'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>',
          'Bolton', '2001', 'valid', 'TRUE', nil, 'FALSE', nil, 'FALSE'
        ]
      end

      it "can export a species without a tribe" do
        atta = create_genus 'Atta', subfamily: ponerinae, tribe: nil
        species = create_species 'Atta robustus', genus: atta

        allow(species).to receive(:author_citation).and_return 'Bolton, 2011'
        allow_alns_for species, 'Bolton'
        allow_year_for species, 2001

        expect(export_taxon(species)[1..16]).to eq [
          'Ponerinae', nil, 'Atta', nil, 'robustus', nil,
          'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>',
          'Bolton', '2001', 'valid', 'TRUE', nil, 'FALSE', nil, 'FALSE'
        ]
      end

      it "exports a species without a subfamily as being in the 'incertae sedis' subfamily" do
        atta = create_genus 'Atta', subfamily: nil, tribe: nil
        species = create_species 'Atta robustus', genus: atta

        allow(species).to receive(:author_citation).and_return 'Bolton, 2011'
        allow_alns_for species, 'Bolton'
        allow_year_for species, 2001

        expect(export_taxon(species)[1..16]).to eq [
          'incertae_sedis', nil, 'Atta', nil, 'robustus', nil,
          'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>',
          'Bolton', '2001', 'valid', 'TRUE', nil, 'FALSE', nil, 'FALSE'
        ]
      end
    end

    describe "Exporting subspecies" do
      it "exports one correctly" do
        atta = create_genus 'Atta', subfamily: ponerinae, tribe: attini
        species = create_species 'Atta robustus', subfamily: ponerinae, genus: atta
        subspecies = create_subspecies 'Atta robustus emeryii', subfamily: ponerinae, genus: atta, species: species

        allow(subspecies).to receive(:author_citation).and_return 'Bolton, 2011'
        allow_alns_for subspecies, 'Bolton'
        allow_year_for subspecies, 2001

        expect(export_taxon(subspecies)[1..16]).to eq [
          'Ponerinae', 'Attini', 'Atta', nil, 'robustus', 'emeryii',
          'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>',
          'Bolton', '2001', 'valid', 'TRUE', nil, 'FALSE', nil, 'FALSE'
        ]
      end

      it "can export a subspecies without a tribe" do
        atta = create_genus 'Atta', subfamily: ponerinae, tribe: nil
        species = create_species 'Atta robustus', subfamily: ponerinae, genus: atta
        subspecies = create_subspecies 'Atta robustus emeryii', genus: atta, species: species

        allow(subspecies).to receive(:author_citation).and_return 'Bolton, 2011'
        allow_alns_for subspecies, 'Bolton'
        allow_year_for subspecies, 2001

        expect(export_taxon(subspecies)[1..16]).to eq [
          'Ponerinae', nil, 'Atta', nil, 'robustus', 'emeryii',
          'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>',
          'Bolton', '2001', 'valid', 'TRUE', nil, 'FALSE', nil, 'FALSE'
        ]
      end

      it "exports a subspecies without a subfamily as being in the 'incertae sedis' subfamily" do
        atta = create_genus 'Atta', subfamily: nil, tribe: nil
        species = create_species 'Atta robustus', subfamily: nil, genus: atta
        subspecies = create_subspecies 'Atta robustus emeryii', subfamily: nil, genus: atta, species: species

        allow(subspecies).to receive(:author_citation).and_return 'Bolton, 2011'
        allow_alns_for subspecies, 'Bolton'
        allow_year_for subspecies, 2001

        expect(export_taxon(subspecies)[1..16]).to eq [
          'incertae_sedis', nil, 'Atta', nil, 'robustus', 'emeryii',
          'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>',
          'Bolton', '2001', 'valid', 'TRUE', nil, 'FALSE', nil, 'FALSE'
        ]
      end
    end
  end

  describe "Current valid name" do
    let(:taxon) { create :genus }

    context 'when taxon is valid' do
      it "returns nil" do
        expect(export_taxon(taxon)[13]).to be_nil
      end
    end

    context "when taxon has a `current_valid_taxon`" do
      let!(:old) { create :genus }

      before { taxon.update! current_valid_taxon: old, status: Status::SYNONYM }

      it "exports the current valid name of the taxon" do
        expect(export_taxon(taxon)[13]).to end_with old.name.name
      end
    end

    context "when there isn't a current_valid_taxon" do
      let!(:junior_synonym) { create :species, :synonym, genus: taxon }

      before do
        senior_synonym = create_species 'Eciton major', genus: taxon
        create :synonym, junior_synonym: junior_synonym, senior_synonym: senior_synonym
      end

      it "looks at synonyms" do
        expect(export_taxon(junior_synonym)[13]).to end_with 'Eciton major'
      end
    end
  end

  describe "Sending all taxa - not just valid" do
    it "can export a junior synonym" do
      taxon = create :genus, :original_combination
      expect(export_taxon(taxon)[11]).to eq 'original combination'
    end

    it "can export a Tribe" do
      taxon = create :tribe
      expect(export_taxon(taxon)).not_to be_nil
    end

    it "can export a Subgenus" do
      taxon = create_subgenus 'Atta (Boyo)'
      expect(export_taxon(taxon)[4]).to eq 'Boyo'
    end
  end

  describe "Sending 'was original combination' so that AntWeb knows when to use parentheses around authorship" do
    it "sends TRUE or FALSE (when TRUE)" do
      taxon = create :genus, :original_combination
      expect(export_taxon(taxon)[14]).to eq 'TRUE'
    end

    it "sends TRUE or FALSE (when FALSE)" do
      taxon = create :genus
      expect(export_taxon(taxon)[14]).to eq 'FALSE'
    end
  end

  describe "Sending 'author_date_html' that includes the full reference in the rollover" do
    let(:taxon) { create :genus }

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
      expect(export_taxon(taxon)[8]).
        to eq '<span title="Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.">Forel, 1874</span>'
    end
  end

  describe "Original combination" do
    let(:recombination) { create :species }
    let(:original_combination) { create :species, :original_combination, current_valid_taxon: recombination }

    before do
      recombination.protonym.name = original_combination.name
      recombination.save!
    end

    it "is the protonym, otherwise" do
      expect(export_taxon(recombination)[15]).to eq original_combination.name.name
    end
  end

  describe "Reference ID" do
    let!(:taxon) { create :genus }

    it "sends the protonym's reference ID" do
      reference_id = export_taxon(taxon)[18]
      expect(reference_id).to eq taxon.authorship_reference.id
    end

    it "sends nil if the protonym's reference is a MissingReference" do
      taxon.protonym.authorship.reference = create :missing_reference
      taxon.save!
      reference_id = export_taxon(taxon)[18]
      expect(reference_id).to be_nil
    end
  end

  describe "Bioregion" do
    it "sends the biogeographic region" do
      taxon = create :genus, biogeographic_region: 'Neotropic'
      expect(export_taxon(taxon)[19]).to eq 'Neotropic'
    end
  end

  describe "Country" do
    it "sends the locality" do
      taxon = create :genus, protonym: create(:protonym, locality: 'Canada')
      expect(export_taxon(taxon)[20]).to eq 'Canada'
    end
  end

  describe "Current valid rank" do
    it "sends the right value for each class" do
      expect(export_taxon(create(:subfamily))[21]).to eq 'Subfamily'
      expect(export_taxon(create(:genus))[21]).to eq 'Genus'
      expect(export_taxon(create(:subgenus))[21]).to eq 'Subgenus'
      expect(export_taxon(create(:species))[21]).to eq 'Species'
      expect(export_taxon(create(:subspecies))[21]).to eq 'Subspecies'
    end
  end

  describe "Current valid parent" do
    let(:subfamily) { create_subfamily 'Dolichoderinae' }
    let(:tribe) { create_tribe 'Attini', subfamily: subfamily }
    let(:genus) { create_genus 'Atta', tribe: tribe, subfamily: subfamily }
    let(:subgenus) { create :subgenus, genus: genus, tribe: tribe, subfamily: subfamily }
    let(:species) { create_species 'Atta betta', genus: genus, subfamily: subfamily }

    it "doesn't punt on a subfamily's family" do
      taxon = create :subfamily
      expect(export_taxon(taxon)[23]).to eq 'Formicidae'
    end

    it "handles a taxon's subfamily" do
      taxon = create :tribe, subfamily: subfamily
      expect(export_taxon(taxon)[23]).to eq 'Dolichoderinae'
    end

    it "doesn't skip over tribe and return the subfamily" do
      taxon = create :genus, tribe: tribe
      expect(export_taxon(taxon)[23]).to eq 'Attini'
    end

    it "returns the subfamily only if there's no tribe" do
      taxon = create :genus, subfamily: subfamily, tribe: nil
      expect(export_taxon(taxon)[23]).to eq 'Dolichoderinae'
    end

    it "skips over subgenus and return the genus", :pending do
      skip "broke a long time ago"

      taxon = create :species, genus: genus, subgenus: subgenus
      expect(export_taxon(taxon)[23]).to eq 'Atta'
    end

    it "handles a taxon's species" do
      taxon = create :subspecies, species: species, genus: genus, subfamily: subfamily
      expect(export_taxon(taxon)[23]).to eq 'Atta betta'
    end

    it "handles a synonym" do
      senior = create_genus 'Eciton', subfamily: subfamily
      junior = create :genus, :synonym, subfamily: subfamily, current_valid_taxon: senior
      taxon = create :species, genus: junior
      create :synonym, senior_synonym: senior, junior_synonym: junior

      expect(export_taxon(taxon)[23]).to eq 'Eciton'
    end

    it "handles a genus without a subfamily" do
      taxon = create :genus, tribe: nil, subfamily: nil
      expect(export_taxon(taxon)[23]).to eq 'Formicidae'
    end

    it "handles a subspecies without a species" do
      taxon = create :subspecies, genus: genus, species: nil, subfamily: nil
      expect(export_taxon(taxon)[23]).to eq 'Atta'
    end
  end

  describe "Test stubbed" do
    let(:taxon) { create :subfamily }

    it "'author date html' # [8]" do
      reference = taxon.authorship_reference
      author = reference.authors_for_keey
      year = reference.citation_year
      title = reference.title
      journal_name = reference.journal.name
      pagination = reference.pagination
      volume = reference.series_volume_issue

      expected = %(<span title="#{author}, B.L. #{year}. #{title}. #{journal_name} #{volume}:#{pagination}.">#{author}, #{year}</span>)
      expect(export_taxon(taxon)[8]).to eq expected
    end
  end

  describe "HEADER" do
    it "is the same as the code" do
      expected = "antcat id\t" +
        "subfamily\t" +
        "tribe\t" +
        "genus\t" +
        "subgenus\t" +
        "species\t" +
        "subspecies\t" +
        "author date\t" +
        "author date html\t" +
        "authors\t" +
        "year\t" +
        "status\t" +
        "available\t" +
        "current valid name\t" +
        "original combination\t" +
        "was original combination\t" +
        "fossil\t" +
        "taxonomic history html\t" +
        "reference id\t" +
        "bioregion\t" +
        "country\t" +
        "current valid rank\t" +
        "hol id\t" +
        "current valid parent"
      expect(described_class::HEADER).to eq expected
    end
  end

  describe "#original_combination" do
    context "when there was no recombining" do
      let!(:taxon) { build_stubbed :genus }

      specify { expect(exporter.send(:original_combination, taxon)).to eq nil }
    end

    context "when there has been some recombining" do
      let!(:original_combination) { create_species 'Atta major' }
      let!(:recombination) { create_species 'Eciton major' }

      before do
        original_combination.status = Status::ORIGINAL_COMBINATION
        original_combination.current_valid_taxon = recombination
        recombination.protonym.name = original_combination.name
        original_combination.save!
        recombination.save!
      end

      it "is the protonym" do
        expect(exporter.send(:original_combination, recombination)).to eq original_combination
      end
    end
  end

  describe "#authorship_html_string" do
    let(:taxon) { create :genus }
    let(:reference) do
      journal = create :journal, name: 'Ants'
      author_name = create :author_name, name: "Forel, A."
      create :article_reference,
        author_names: [author_name], citation_year: '1874', title: 'Format',
        journal: journal, series_volume_issue: '1:1', pagination: '2'
    end

    it "formats references into HTML" do
      taxon.protonym.authorship.reference = reference
      expected = '<span title="Forel, A. 1874. Format. Ants 1:1:2.">Forel, 1874</span>'
      expect(exporter.send(:authorship_html_string, taxon)).to eq expected
    end
  end

  describe "#export_history" do
    context "a genus" do
      let!(:shared_name) { create :genus_name, name: 'Atta' }
      let!(:protonym) do
        author_name = create :author_name, name: 'Bolton, B.'
        reference = ArticleReference.new author_names: [author_name],
          title: 'Ants I have known',
          citation_year: '2010a',
          journal: create(:journal, name: 'Psyche'),
          series_volume_issue: '1',
          pagination: '2'
        authorship = create :citation, reference: reference, pages: '12'
        create :protonym, name: shared_name, authorship: authorship
      end

      let!(:genus) { create :genus, name: shared_name, protonym: protonym, hol_id: 9999 }
      let!(:species) { create_species 'Atta major', genus: genus }

      it "formats a taxon's history for AntWeb" do
        authorship_reference_id = genus.authorship_reference.id

        genus.update type_name: species.name
        genus.history_items.create taxt: "Taxon: {tax #{species.id}} Name: {nam #{species.name.id}}"

        a_reference = create :article_reference, doi: "10.10.1038/nphys1170"
        a_tribe = create :tribe
        genus.reference_sections.create title_taxt: "Subfamily and tribe {tax #{a_tribe.id}}",
          references_taxt: "{ref #{a_reference.id}}: 766 (diagnosis);"
        ref_author = a_reference.authors_for_keey
        ref_year = a_reference.citation_year
        ref_title = a_reference.title
        ref_journal_name = a_reference.journal.name
        ref_pagination = a_reference.pagination
        ref_volume = a_reference.series_volume_issue
        ref_doi = a_reference.doi

        expect(export_taxon(genus)[17]).to eq(
          %(<div class="antcat_taxon">) +

            # statistics
            %(<div class="statistics">) +
              %(<p>1 species</p>) +
            %(</div>) +

            # headline
            %(<div>) +
              # protonym
              %(<b><span><i>Atta</i></span></b> ) +

              # authorship
              %(<span>) +
                %(<a title="Bolton, B. 2010a. Ants I have known. Psyche 1:2." href="http://antcat.org/references/#{authorship_reference_id}">Bolton, 2010a</a>) +
                %(: 12) +
              %(</span>) +
              %(. ) +

              # type
              %(<span>Type-species: <a class="link_to_external_site" href="http://www.antcat.org/catalog/#{species.id}"><i>Atta major</i></a>.</span>) +
              %( ) +
              # links
              %(<a class="link_to_external_site" href="http://www.antcat.org/catalog/#{genus.id}">AntCat</a>) +
              %( ) +
              %(<a class="link_to_external_site" href="http://www.antwiki.org/wiki/Atta">AntWiki</a>) +
              %( ) +
              %(<a class="link_to_external_site" href="http://hol.osu.edu/index.html?id=9999">HOL</a>) +

            %(</div>) +

            # taxonomic history
            %(<p><b>Taxonomic history</b></p>) +
            %(<div><div>) +
              %(<table><tr><td>) +
                %(Taxon: <a class="link_to_external_site" href="http://www.antcat.org/catalog/#{species.id}"><i>Atta major</i></a> Name: <i>Atta major</i>.) +
              %(</td></tr></table>) +
            %(</div></div>) +

            # references
            %(<div>) +
              %(<div>) +
                %(<div>Subfamily and tribe ) +
                  %(<a class="link_to_external_site" href="http://www.antcat.org/catalog/#{a_tribe.id}">) +
                    %(#{a_tribe.name_cache}) +
                  %(</a>) +
                %(</div>) +
                %(<div>) +
                  %(<a title="#{ref_author}, B.L. #{ref_year}. #{ref_title}. #{ref_journal_name} #{ref_volume}:#{ref_pagination}." href="http://antcat.org/references/#{a_reference.id}">) +
                    %(#{ref_author}, #{ref_year}) +
                  %(</a> ) +
                  %(<a href="http://dx.doi.org/#{ref_doi}">#{ref_doi}</a>) +
                  %{: 766 (diagnosis);} +
                %(</div>) +
              %(</div>) +
            %(</div>) +

          %(</div>)
        )
      end
    end
  end
end
# rubocop:enable RSpec/SubjectStub
