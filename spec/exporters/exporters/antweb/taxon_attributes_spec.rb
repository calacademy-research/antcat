# frozen_string_literal: true

require 'rails_helper'

describe Exporters::Antweb::TaxonAttributes do
  include TestLinksHelpers

  describe "#call" do
    describe "[0]: `antcat_id`" do
      let(:taxon) { create :family }

      specify { expect(described_class[taxon][:antcat_id]).to eq taxon.id }
    end

    describe "[8]: `author date html`" do
      let(:taxon) { create :family }

      specify do
        reference = taxon.authorship_reference
        expect(described_class[taxon][:author_date_html]).
          to eq %(<span title="#{reference.decorate.plain_text}">#{reference.keey}</span>)
      end
    end

    describe "[11]: `status`" do
      let(:taxon) { create :family }

      specify { expect(described_class[taxon][:status]).to eq taxon.status }
    end

    describe "[12]: `available`" do
      context "when taxon is valid" do
        let(:taxon) { create :family }

        specify { expect(described_class[taxon][:available]).to eq true }
      end

      context "when taxon is not valid" do
        let(:taxon) { create :family, :synonym }

        specify { expect(described_class[taxon][:available]).to eq false }
      end
    end

    describe "[13]: `current valid name`" do
      context "when taxon dhas no `current_valid_taxon`" do
        let(:taxon) { create :genus }

        specify { expect(described_class[taxon][:current_valid_name]).to eq nil }
      end

      context "when taxon has a `current_valid_taxon`" do
        let(:current_valid_taxon) { create :genus }
        let(:taxon) { create :genus, :synonym, current_valid_taxon: current_valid_taxon }

        it "exports the current valid name of the taxon" do
          expect(described_class[taxon][:current_valid_name]).to eq "#{taxon.subfamily.name.name} #{current_valid_taxon.name.name}"
        end
      end
    end

    # So that AntWeb knows when to use parentheses around authorship.
    describe "[14]: `original combination`" do
      context "when taxon is an original combination" do
        let(:taxon) { create :genus, :original_combination }

        specify { expect(described_class[taxon][:original_combination]).to eq true }
      end

      context "when taxon is not an original combination" do
        let(:taxon) { create :genus }

        specify { expect(described_class[taxon][:original_combination]).to eq false }
      end
    end

    describe "[15]: `was original combination`" do
      context "when there was no recombining" do
        let(:taxon) { create :family }

        specify { expect(described_class[taxon][:was_original_combination]).to eq nil }
      end

      context "when there has been some recombining" do
        let(:recombination) { create :species }
        let(:original_combination) do
          create :species, :obsolete_combination, :original_combination, current_valid_taxon: recombination
        end

        before do
          recombination.protonym.name = original_combination.name
          recombination.save!
        end

        it "is the protonym" do
          expect(described_class[recombination][:was_original_combination]).to eq original_combination.name.name
        end
      end
    end

    describe "[16]: `fossil`" do
      context "when taxon is not fossil" do
        let(:taxon) { create :family }

        specify { expect(described_class[taxon][:fossil]).to eq false }
      end

      context "when taxon is fossil" do
        let(:taxon) { create :family, :fossil }

        specify { expect(described_class[taxon][:fossil]).to eq true }
      end
    end

    describe "[17]: `taxonomic history html` (child lists only)" do
      let(:taxon) { create :subfamily }
      let!(:tribe) { create :tribe, subfamily: taxon }

      specify do
        expect(described_class[taxon][:taxonomic_history_html]).
          to include(%(<div><span class="caption">Tribes of #{taxon.name_cache}</span>: #{antweb_taxon_link(tribe)}</div>))
      end
    end

    describe "[17]: `taxonomic history html`" do
      let(:taxon) { create :genus, hol_id: 9999 }
      let!(:type_species) { create :species, genus: taxon }
      let(:taxt_reference) { create :any_reference }

      before do
        taxon.protonym.type_name = create :type_name, :by_monotypy, taxon: type_species
        taxon.history_items.create!(taxt: "Taxon: {tax #{type_species.id}}")
        taxon.reference_sections.create!(title_taxt: "Title", references_taxt: "{ref #{taxt_reference.id}}: 766")
      end

      it "formats a taxon's history for AntWeb" do
        expect(described_class[taxon][:taxonomic_history_html]).to eq(
          %(<div class="antcat_taxon">) +
            # Statistics.
            %(<p>Extant: 1 valid species</p>) +

            # Protonym synopsis.
            %(<div>) +
              # Protonym.
              %(<b><i>#{taxon.protonym.name.name}</i></b> ) +

              # Authorship.
              AntwebFormatter.link_to_reference(taxon.authorship_reference) +
              %(: #{taxon.protonym.authorship.pages}. ) +

              # Type.
              %(Type-species: #{antweb_taxon_link(type_species)}, by monotypy.  ) +

              # Links.
              %(#{antweb_taxon_link(taxon, 'AntCat')} ) +
              %(<a class="external-link" href="https://www.antwiki.org/wiki/#{taxon.name_cache}">AntWiki</a> ) +
              %(<a class="external-link" href="http://hol.osu.edu/index.html?id=#{taxon.hol_id}">HOL</a>) +
            %(</div>) +

            # History items.
            %(<p><b>Taxonomic history</b></p>) +
            %(<div>) +
              %(<div>Taxon: #{antweb_taxon_link(type_species)}.</div>) +
            %(</div>) +

            # Reference sections.
            %(<div>) +
              %(<div>) +
                %(<div>Title</div>) +
                %(<div>#{AntwebFormatter.link_to_reference(taxt_reference)}: 766</div>) +
              %(</div>) +
            %(</div>) +
          %(</div>)
        )
      end
    end

    describe "[18]: `reference id`" do
      let(:taxon) { create :family }

      it "sends the protonym's reference ID" do
        expect(described_class[taxon][:reference_id]).to eq taxon.authorship_reference.id
      end
    end

    describe "[19]: `bioregion`" do
      let(:protonym) { create :protonym, :species_group_name, biogeographic_region: Protonym::NEARCTIC_REGION }
      let(:taxon) { create :species, protonym: protonym }

      specify { expect(described_class[taxon][:bioregion]).to eq Protonym::NEARCTIC_REGION }
    end

    describe "[20]: `country`" do
      let(:taxon) { create :genus, protonym: create(:protonym, locality: 'Canada') }

      specify { expect(described_class[taxon][:country]).to eq 'Canada' }
    end

    describe "[21]: `current valid rank`" do
      let(:taxon) { create :subfamily }

      specify { expect(described_class[taxon][:current_valid_rank]).to eq 'Subfamily' }
    end

    describe "[23]: `current valid parent`" do
      let(:subfamily) { create :subfamily }
      let(:tribe) { create :tribe, subfamily: subfamily }
      let(:genus) { create :genus, name_string: 'Atta', tribe: tribe, subfamily: subfamily }

      context 'when taxon is a subfamily' do
        it "doesn't punt on a subfamily's family" do
          expect(described_class[subfamily][:current_valid_parent]).to eq 'Formicidae'
        end
      end

      context 'when taxon is a tribe' do
        let(:taxon) { create :tribe, subfamily: subfamily }

        it "returns the subfamily" do
          expect(described_class[taxon][:current_valid_parent]).to eq subfamily.name_cache
        end
      end

      context 'when taxon is a genus' do
        context 'when genus has a tribe' do
          let(:taxon) { create :genus, tribe: tribe }

          it "returns the tribe" do
            expect(described_class[taxon][:current_valid_parent]).to eq tribe.name_cache
          end
        end

        context 'when genus has no tribe' do
          let(:taxon) { create :genus, subfamily: subfamily, tribe: nil }

          it "returns the subfamily" do
            expect(described_class[taxon][:current_valid_parent]).to eq subfamily.name_cache
          end
        end
      end

      context 'when taxon is a species' do
        context 'when species has a subgenus' do
          let(:subgenus) { create :subgenus, genus: genus }
          let(:taxon) { create :species, genus: genus, subgenus: subgenus }

          it "skips subgenus and returns the genus" do
            expect(described_class[taxon][:current_valid_parent]).to eq genus.name_cache
          end
        end
      end

      context 'when taxon is a subspecies' do
        let(:species) { create :species, name_string: 'Atta betta', genus: genus, subfamily: subfamily }
        let(:taxon) { create :subspecies, species: species }

        it "handles a taxon's species" do
          expect(described_class[taxon][:current_valid_parent]).to eq 'Atta betta'
        end
      end

      context 'when taxon is a synonym' do
        let(:senior) { create :genus }
        let(:taxon) do
          junior = create :genus, :synonym, current_valid_taxon: senior
          create :species, genus: junior
        end

        specify { expect(described_class[taxon][:current_valid_parent]).to eq senior.name_cache }
      end

      context 'when taxon is a genus without a subfamily' do
        let(:taxon) { create :genus, tribe: nil, subfamily: nil }

        it "defaults to Formicidae" do
          expect(described_class[taxon][:current_valid_parent]).to eq 'Formicidae'
        end
      end
    end
  end
end
