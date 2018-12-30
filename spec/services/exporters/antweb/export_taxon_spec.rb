require 'spec_helper'

describe Exporters::Antweb::ExportTaxon do
  def export_taxon taxon
    described_class.new.call(taxon)
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

  describe "#call" do
    let(:taxon) { create :family }

    describe "[0]: `antcat_id`" do
      specify { expect(export_taxon(taxon)[0]).to eq taxon.id }
    end

    describe "[1-6]: `subfamily`, ``tribe, `genus`, `subgenus`, `species` and `subspecies`" do
      let(:subfamily) { create :subfamily }
      let(:tribe) { create :tribe, subfamily: subfamily }

      it "can export a subfamily" do
        expect(export_taxon(subfamily)[1..6]).to eq [
          subfamily.name_cache, nil, nil, nil, nil, nil
        ]
      end

      it "can export a genus" do
        genus = create :genus, subfamily: subfamily, tribe: tribe
        expect(export_taxon(genus)[1..6]).to eq [
          subfamily.name_cache, tribe.name_cache, genus.name_cache, nil, nil, nil
        ]
      end

      it "can export a genus without a tribe" do
        genus = create :genus, subfamily: subfamily, tribe: nil
        expect(export_taxon(genus)[1..6]).to eq [
          subfamily.name_cache, nil, genus.name_cache, nil, nil, nil
        ]
      end

      it "can export a genus without a subfamily as being in 'incertae_sedis'" do
        genus = create :genus, tribe: nil, subfamily: nil
        expect(export_taxon(genus)[1..6]).to eq [
          'incertae_sedis', nil, genus.name_cache, nil, nil, nil
        ]
      end

      it "can export a Subgenus" do
        taxon = create :subgenus, name: create(:subgenus_name, name: 'Atta (Boyo)')
        expect(export_taxon(taxon)[4]).to eq 'Boyo'
      end

      describe "Exporting species" do
        it "exports one correctly" do
          genus = create :genus, tribe: tribe
          species = create_species 'Atta robustus', genus: genus

          expect(export_taxon(species)[1..6]).to eq [
            subfamily.name_cache, tribe.name_cache, genus.name_cache, nil, 'robustus', nil
          ]
        end

        it "can export a species without a tribe" do
          genus = create :genus, subfamily: subfamily, tribe: nil
          species = create_species 'Atta robustus', genus: genus

          expect(export_taxon(species)[1..6]).to eq [
            subfamily.name_cache, nil, genus.name_cache, nil, 'robustus', nil
          ]
        end

        it "exports a species without a subfamily as being in the 'incertae sedis' subfamily" do
          genus = create :genus, subfamily: nil, tribe: nil
          species = create_species 'Atta robustus', genus: genus

          expect(export_taxon(species)[1..6]).to eq [
            'incertae_sedis', nil, genus.name_cache, nil, 'robustus', nil
          ]
        end
      end

      describe "Exporting subspecies" do
        it "exports one correctly" do
          genus = create :genus, subfamily: subfamily, tribe: tribe
          species = create_species 'Atta robustus', subfamily: subfamily, genus: genus
          subspecies = create_subspecies 'Atta robustus emeryii', subfamily: subfamily, genus: genus, species: species

          expect(export_taxon(subspecies)[1..6]).to eq [
            subfamily.name_cache, tribe.name_cache, genus.name_cache, nil, 'robustus', 'emeryii'
          ]
        end

        it "can export a subspecies without a tribe" do
          genus = create :genus, subfamily: subfamily, tribe: nil
          species = create_species 'Atta robustus', subfamily: subfamily, genus: genus
          subspecies = create_subspecies 'Atta robustus emeryii', genus: genus, species: species

          expect(export_taxon(subspecies)[1..6]).to eq [
            subfamily.name_cache, nil, genus.name_cache, nil, 'robustus', 'emeryii'
          ]
        end

        it "exports a subspecies without a subfamily as being in the 'incertae sedis' subfamily" do
          genus = create :genus, subfamily: nil, tribe: nil
          species = create_species 'Atta robustus', subfamily: nil, genus: genus
          subspecies = create_subspecies 'Atta robustus emeryii', subfamily: nil, genus: genus, species: species

          expect(export_taxon(subspecies)[1..6]).to eq [
            'incertae_sedis', nil, genus.name_cache, nil, 'robustus', 'emeryii'
          ]
        end
      end
    end

    describe "[8]: `author date html`" do
      specify do
        reference = taxon.authorship_reference
        expect(export_taxon(taxon)[8]).
          to eq %(<span title="#{reference.decorate.plain_text}">#{reference.keey}</span>)
      end
    end

    describe "[11]: `status`" do
      specify { expect(export_taxon(taxon)[11]).to eq taxon.status }
    end

    describe "[12]: `available`" do
      context "when taxon is valid" do
        specify { expect(export_taxon(taxon)[12]).to eq 'TRUE' }
      end

      context "when taxon is not valid" do
        let(:taxon) { create :family, :synonym }

        specify { expect(export_taxon(taxon)[12]).to eq 'FALSE' }
      end
    end

    describe "[13]: `current valid name`" do
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

    # So that AntWeb knows when to use parentheses around authorship.
    # NOTE: This and `was original combination` have been mixed up, but it's been like that forever.
    describe "[14]: `original combination`" do
      specify do
        taxon = create :genus, :original_combination
        expect(export_taxon(taxon)[14]).to eq 'TRUE'
      end

      specify do
        expect(export_taxon(taxon)[14]).to eq 'FALSE'
      end
    end

    # NOTE: See above.
    describe "[15]: `was original combination`" do
      context "when there was no recombining" do
        specify { expect(export_taxon(taxon)[15]).to eq nil }
      end

      context "when there has been some recombining" do
        let(:recombination) { create :species }
        let(:original_combination) { create :species, :original_combination, current_valid_taxon: recombination }

        before do
          recombination.protonym.name = original_combination.name
          recombination.save!
        end

        it "is the protonym" do
          expect(export_taxon(recombination)[15]).to eq original_combination.name.name
        end
      end
    end

    describe "[16]: `fossil`" do
      context "when taxon is not fossil" do
        specify { expect(export_taxon(taxon)[16]).to eq 'FALSE' }
      end

      context "when taxon is fossil" do
        let(:taxon) { create :family, fossil: true }

        specify { expect(export_taxon(taxon)[16]).to eq 'TRUE' }
      end
    end

    describe "[17]: `taxonomic history html`" do
      let!(:atta_name) { create :genus_name, name: 'Atta' }
      let!(:authorship_reference) do
        author_name = create :author_name, name: 'Bolton, B.'
        create :article_reference, author_names: [author_name],
          title: 'Ants I have known',
          citation_year: '2010a',
          journal: create(:journal, name: 'Psyche'),
          series_volume_issue: '1',
          pagination: '2'
      end
      let!(:protonym) do
        authorship = create :citation, reference: authorship_reference, pages: '12'
        create :protonym, name: atta_name, authorship: authorship
      end
      let!(:genus) { create :genus, name: atta_name, protonym: protonym, hol_id: 9999 }
      let!(:species) { create_species 'Atta major', genus: genus }
      let!(:a_reference) { create :article_reference, doi: "10.10.1038/nphys1170" }

      before do
        create :species, :unavailable, genus: genus # For the statistics.
        genus.update type_name: species.name
        genus.history_items.create taxt: "Taxon: {tax #{species.id}} Name: {nam #{species.name.id}}"
        genus.reference_sections.create title_taxt: "Title", references_taxt: "{ref #{a_reference.id}}: 766;"
      end

      it "formats a taxon's history for AntWeb" do
        ref_author = a_reference.authors_for_keey
        ref_year = a_reference.citation_year
        ref_title = a_reference.title
        ref_journal_name = a_reference.journal.name
        ref_pagination = a_reference.pagination
        ref_volume = a_reference.series_volume_issue
        ref_title_tag = "#{ref_author}, B.L. #{ref_year}. #{ref_title}. #{ref_journal_name} #{ref_volume}:#{ref_pagination}."
        ref_doi = a_reference.doi

        expect(export_taxon(genus)[17]).to eq(
          %(<div class="antcat_taxon">) +

            # statistics
            %(<p>Extant: 1 valid species</p>) +

            # headline
            %(<div>) +
              # protonym
              %(<b><span><i>Atta</i></span></b> ) +

              # authorship
              %(<span>) +
                %(<a title="Bolton, B. 2010a. Ants I have known. Psyche 1:2." href="http://antcat.org/references/#{authorship_reference.id}">Bolton, 2010a</a>) +
                %(: 12) +
              %(</span>) +
              %(. ) +

              # type
              %(<span>Type-species: <a href="http://www.antcat.org/catalog/#{species.id}"><i>Atta major</i></a>.</span> ) +
              %( ) +
              # links
              %(<a href="http://www.antcat.org/catalog/#{genus.id}">AntCat</a>) +
              %( ) +
              %(<a class="external-link" href="http://www.antwiki.org/wiki/Atta">AntWiki</a>) +
              %( ) +
              %(<a class="external-link" href="http://hol.osu.edu/index.html?id=9999">HOL</a>) +

            %(</div>) +

            # taxonomic history
            %(<p><b>Taxonomic history</b></p>) +
            %(<div><div>) +
              %(<table><tr><td>) +
                %(Taxon: <a href="http://www.antcat.org/catalog/#{species.id}"><i>Atta major</i></a> Name: <i>Atta major</i>.) +
              %(</td></tr></table>) +
            %(</div></div>) +

            # references
            %(<div>) +
              %(<div>) +
                %(<div>Title</div>) +
                %(<div>) +
                  %(<a title="#{ref_title_tag}" href="http://antcat.org/references/#{a_reference.id}">) +
                    %(#{ref_author}, #{ref_year}) +
                  %(</a> ) +
                  %(<a class="external-link" href="https://doi.org/#{ref_doi}">#{ref_doi}</a>) +
                  %(: 766;) +
                %(</div>) +
              %(</div>) +
            %(</div>) +

          %(</div>)
        )
      end
    end

    describe "[18]: `reference id`" do
      it "sends the protonym's reference ID" do
        expect(export_taxon(taxon)[18]).to eq taxon.authorship_reference.id
      end
    end

    describe "[19]: `bioregion`" do
      let!(:taxon) { create :genus, biogeographic_region: 'Neotropic' }

      specify { expect(export_taxon(taxon)[19]).to eq 'Neotropic' }
    end

    describe "[20]: `country`" do
      let!(:taxon) { create :genus, protonym: create(:protonym, locality: 'Canada') }

      specify { expect(export_taxon(taxon)[20]).to eq 'Canada' }
    end

    describe "[21]: `current valid rank`" do
      it "sends the right value for each class" do
        expect(export_taxon(create(:subfamily))[21]).to eq 'Subfamily'
        expect(export_taxon(create(:genus))[21]).to eq 'Genus'
        expect(export_taxon(create(:subgenus))[21]).to eq 'Subgenus'
        expect(export_taxon(create(:species))[21]).to eq 'Species'
        expect(export_taxon(create(:subspecies))[21]).to eq 'Subspecies'
      end
    end

    describe "[23]: `current valid parent`" do
      let(:subfamily) { create :subfamily }
      let(:tribe) { create :tribe, subfamily: subfamily }
      let(:genus) { create_genus 'Atta', tribe: tribe, subfamily: subfamily }
      let(:subgenus) { create :subgenus, genus: genus, tribe: tribe, subfamily: subfamily }
      let(:species) { create_species 'Atta betta', genus: genus, subfamily: subfamily }

      it "doesn't punt on a subfamily's family" do
        expect(export_taxon(subfamily)[23]).to eq 'Formicidae'
      end

      it "handles a taxon's subfamily" do
        taxon = create :tribe, subfamily: subfamily
        expect(export_taxon(taxon)[23]).to eq subfamily.name_cache
      end

      it "doesn't skip over tribe and return the subfamily" do
        taxon = create :genus, tribe: tribe
        expect(export_taxon(taxon)[23]).to eq tribe.name_cache
      end

      it "returns the subfamily only if there's no tribe" do
        taxon = create :genus, subfamily: subfamily, tribe: nil
        expect(export_taxon(taxon)[23]).to eq subfamily.name_cache
      end

      it "skips over subgenus and return the genus", :pending do
        skip "broke a long time ago"

        taxon = create :species, genus: genus, subgenus: subgenus
        expect(export_taxon(taxon)[23]).to eq genus.name_cache
      end

      it "handles a taxon's species" do
        taxon = create :subspecies, species: species
        expect(export_taxon(taxon)[23]).to eq 'Atta betta'
      end

      it "handles a synonym" do
        senior = create :genus
        junior = create :genus, :synonym, current_valid_taxon: senior
        taxon = create :species, genus: junior
        create :synonym, senior_synonym: senior, junior_synonym: junior

        expect(export_taxon(taxon)[23]).to eq senior.name_cache
      end

      it "handles a genus without a subfamily" do
        taxon = create :genus, tribe: nil, subfamily: nil
        expect(export_taxon(taxon)[23]).to eq 'Formicidae'
      end

      it "handles a subspecies without a species" do
        taxon = create :subspecies, genus: genus, species: nil
        expect(export_taxon(taxon)[23]).to eq genus.name_cache
      end
    end
  end
end
