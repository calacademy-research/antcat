# frozen_string_literal: true

require 'rails_helper'

# NOTE: `dummy` is used to avoid defaulting to `Taxon.none`.
describe Catalog::AdvancedSearchQuery do
  describe "#call" do
    context "when no meaningful search parameters are given" do
      specify { expect(described_class[year: '']).to be_empty }
    end

    describe "searching by validity" do
      let!(:valid) { create :family }
      let!(:synonym) { create :family, :synonym }

      specify do
        expect(described_class[valid_only: true, dummy: 'see NOTE']).to eq [valid]
        expect(described_class[valid_only: false, dummy: 'see NOTE']).to match_array [valid, synonym]
      end
    end

    describe "searching for taxa with history items" do
      let!(:with_history) { create :family, :with_history_item }
      let!(:without_history) { create :family }

      specify do
        expect(described_class[history_items: nil, dummy: 'see NOTE']).
          to match_array [with_history, without_history]
      end

      specify do
        expect(described_class[history_items: described_class::MUST_HAVE_HISTORY_ITEMS, dummy: 'see NOTE']).
          to eq [with_history]
      end

      specify do
        expect(described_class[history_items: described_class::CANNOT_HAVE_HISTORY_ITEMS, dummy: 'see NOTE']).
          to eq [without_history]
      end
    end

    describe "searching by year" do
      let!(:taxon) { create :subfamily }

      before do
        reference = create :any_reference, citation_year: '1977'
        taxon.protonym.authorship.update!(reference: reference)
      end

      specify do
        expect(described_class[year: "1977"]).to eq [taxon]
        expect(described_class[year: "1979"]).to be_empty
      end
    end

    describe "searching by protonym" do
      let!(:protonym) { create :protonym, name: create(:species_name, name: 'Formica fusca') }
      let!(:taxon) { create :species, name_string: 'Lasius niger', protonym: protonym }

      specify do
        expect(described_class[protonym: 'fusca']).to eq [taxon]
        expect(described_class[protonym: 'fusc']).to eq [taxon]
        expect(described_class[protonym: 'niger']).to eq []
      end

      context 'when query contains redundant spacing' do
        specify { expect(described_class[protonym: ' Formica fusca ']).to eq [taxon] }
      end
    end

    describe "searching by ranks" do
      let!(:subfamily) { create :subfamily }

      specify do
        expect(described_class[type: Rank::SUBFAMILY]).to eq [subfamily]
      end
    end

    describe "searching by name" do
      let!(:f_fusca) { create :species, name_string: 'Formica fusca' }
      let!(:f_fusca_rufa) { create :subspecies, name_string: 'Formica fusca rufa' }
      let!(:l_fusca) { create :species, name_string: 'Lasius fusca' }

      specify do
        expect(described_class[name: 'fusca', name_search_type: described_class::NAME_CONTAINS]).
          to match_array [f_fusca, f_fusca_rufa, l_fusca]
      end

      specify do
        expect(described_class[name: 'Formica fusca', name_search_type: described_class::NAME_MATCHES]).
          to eq [f_fusca]
      end

      specify do
        expect(described_class[name: 'Formica fusca', name_search_type: described_class::NAME_BEGINS_WITH]).
          to match_array [f_fusca, f_fusca_rufa]
      end

      context 'when query contains redundant spacing' do
        specify { expect(described_class[name: ' Lasius fusca ']).to eq [l_fusca] }
      end
    end

    describe "searching by epithet" do
      let!(:taxon) { create :species, name_string: 'Lasius niger' }

      it 'only considers exact matches' do
        expect(described_class[epithet: 'niger']).to eq [taxon]
        expect(described_class[epithet: 'nige']).to eq []
      end

      context 'when query contains redundant spacing' do
        specify { expect(described_class[epithet: ' niger ']).to eq [taxon] }
      end
    end

    describe "searching by genus" do
      let!(:taxon) do
        create :species, name_string: 'Lasius niger', genus: create(:genus, name_string: 'Lasius')
      end

      specify do
        expect(described_class[genus: 'Lasius']).to eq [taxon]
        expect(described_class[genus: 'Atta']).to eq []
      end

      context 'when query contains redundant spacing' do
        specify { expect(described_class[genus: ' Lasius ']).to eq [taxon] }
      end
    end

    describe "searching by author name" do
      it "finds the taxa for the author's references that are part of citations in the protonym" do
        reference = create :any_reference,
          author_names: [create(:author_name, name: 'Bolton'), create(:author_name, name: 'Fisher')]
        taxon = create :any_taxon
        taxon.protonym.authorship.update!(reference: reference)

        expect(described_class[author_name: 'Fisher']).to eq [taxon]
      end

      describe "when author in protonym has many different names" do
        let!(:barry_taxon) { create :genus }
        let!(:bolton_taxon) { create :genus }
        let!(:author) { create :author }
        let!(:bolton_reference) do
          create :any_reference, author_names: [create(:author_name, name: 'Bolton', author: author)]
        end
        let!(:barry_reference) do
          create :any_reference, author_names: [create(:author_name, name: 'Barry', author: author)]
        end

        before do
          barry_taxon.protonym.authorship.update!(reference: barry_reference)
          bolton_taxon.protonym.authorship.update!(reference: bolton_reference)
        end

        specify do
          expect(described_class[author_name: 'Bolton']).to match_array [barry_taxon, bolton_taxon]
        end
      end
    end

    describe "searching by `incertae_sedis_in`" do
      let!(:taxon) { create :species, :incertae_sedis_in_family }

      before do
        create :species
      end

      specify do
        expect(described_class[incertae_sedis_in: Rank::FAMILY]).to eq [taxon]
        expect(described_class[incertae_sedis_in: Rank::SUBFAMILY]).to eq []
      end
    end

    describe "searching for locality" do
      let!(:indonesia) { create :protonym, locality: 'Indonesia (Bhutan)' }
      let!(:taxon) { create :genus, protonym: indonesia }

      before do
        china = create :protonym, locality: 'China'
        create :genus, protonym: china
      end

      it "only returns taxa with that locality" do
        expect(described_class[locality: 'Indonesia']).to eq [taxon]
      end
    end

    describe "searching for biogeographic region" do
      it "only returns taxa with that biogeographic_region" do
        create :species, protonym: create(:protonym, :species_group_name, biogeographic_region: Protonym::NEOTROPIC_REGION)
        indomanayan_species = create :species,
          protonym: create(:protonym, :species_group_name, biogeographic_region: Protonym::NEARCTIC_REGION)
        no_region_species = create :species

        expect(described_class[biogeographic_region: Protonym::NEARCTIC_REGION]).to eq [indomanayan_species]
        # NOTE: `type: Rank::SPECIES` is to filter out unrelated taxa created in factories.
        expect(described_class[type: Rank::SPECIES, biogeographic_region: described_class::BIOGEOGRAPHIC_REGION_NONE]).
          to eq [no_region_species]
      end
    end

    describe "searching type fields" do
      let!(:one) { create :species, protonym: create(:protonym, :species_group_name, primary_type_information_taxt: 'one') }
      let!(:two) { create :species, protonym: create(:protonym, :species_group_name, secondary_type_information_taxt: 'one two') }
      let!(:three) { create :species, protonym: create(:protonym, :species_group_name, type_notes_taxt: 'one two three') }

      before { create :species, protonym: create(:protonym, :species_group_name, primary_type_information_taxt: 'unrelated') }

      it "returns taxa with type fields matching the query" do
        expect(described_class[type_information: 'one']).to match_array [one, two, three]
        expect(described_class[type_information: 'two']).to match_array [two, three]
        expect(described_class[type_information: 'three']).to eq [three]
      end
    end

    describe "searching for forms" do
      it "only returns taxa with those forms" do
        protonym = create :protonym, :species_group_name, forms: 'w.q.'
        atta = create :species, protonym: protonym

        protonym = create :protonym, :species_group_name, forms: 'q.'
        create :species, protonym: protonym

        expect(described_class[forms: 'w.']).to eq [atta]
      end
    end

    describe "searching by status" do
      let!(:valid) { create :any_taxon, :valid }
      let!(:synonym) { create :any_taxon, :synonym }

      specify do
        expect(described_class[status: Status::VALID]).to eq [valid]
        expect(described_class[status: Status::HOMONYM]).to be_empty

        expect(described_class[status: "", dummy: 'see NOTE']).to match_array [valid, synonym]
        expect(described_class[status: ""]).to be_empty
      end
    end

    describe "searching by fossil" do
      let!(:extant) { create :any_taxon }
      let!(:fossil) { create :any_taxon, :fossil }

      specify { expect(described_class[fossil: "", dummy: 'see NOTE']).to match_array [extant, fossil] }
      specify { expect(described_class[fossil: "true"]).to eq [fossil] }
      specify { expect(described_class[fossil: "false"]).to eq [extant] }
    end

    describe "searching by nomen nudum" do
      let!(:no_match) { create :any_taxon }
      let!(:yes_match) { create :any_taxon, :unavailable, nomen_nudum: true }

      specify { expect(described_class[nomen_nudum: "", dummy: 'see NOTE']).to match_array [no_match, yes_match] }
      specify { expect(described_class[nomen_nudum: "true"]).to eq [yes_match] }
      specify { expect(described_class[nomen_nudum: "false"]).to eq [no_match] }
    end

    describe "searching by unresolved junior homonym" do
      let!(:no_match) { create :any_taxon }
      let!(:yes_match) { create :any_taxon, :unresolved_homonym }

      specify { expect(described_class[unresolved_homonym: "", dummy: 'see NOTE']).to match_array [no_match, yes_match] }
      specify { expect(described_class[unresolved_homonym: "true"]).to eq [yes_match] }
      specify { expect(described_class[unresolved_homonym: "false"]).to eq [no_match] }
    end

    describe "searching by ichnotaxon" do
      let!(:no_match) { create :any_taxon }
      let!(:yes_match) { create :any_taxon, :fossil, ichnotaxon: true }

      specify { expect(described_class[ichnotaxon: "", dummy: 'see NOTE']).to match_array [no_match, yes_match] }
      specify { expect(described_class[ichnotaxon: "true"]).to eq [yes_match] }
      specify { expect(described_class[ichnotaxon: "false"]).to eq [no_match] }
    end

    describe "searching by Hong" do
      let!(:no_match) { create :any_taxon }
      let!(:yes_match) { create :any_taxon, hong: true }

      specify { expect(described_class[hong: "", dummy: 'see NOTE']).to match_array [no_match, yes_match] }
      specify { expect(described_class[hong: "true"]).to eq [yes_match] }
      specify { expect(described_class[hong: "false"]).to eq [no_match] }
    end

    describe "searching by collective group name" do
      let!(:no_match) { create :any_taxon }
      let!(:yes_match) { create :any_taxon, :fossil, collective_group_name: true }

      specify { expect(described_class[collective_group_name: "", dummy: 'see NOTE']).to match_array [no_match, yes_match] }
      specify { expect(described_class[collective_group_name: "true"]).to eq [yes_match] }
      specify { expect(described_class[collective_group_name: "false"]).to eq [no_match] }
    end
  end
end
