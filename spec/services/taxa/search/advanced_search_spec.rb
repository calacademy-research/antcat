# TODO: Cleanup after extracting into service object.

require 'rails_helper'

describe Taxa::Search::AdvancedSearch do
  describe "#call" do
    context "when no meaningful search parameters are given" do
      specify { expect(described_class[year: '']).to be_empty }
    end

    describe "searching by validity" do
      let!(:valid) { create :family }
      let!(:synonym) { create :family, :synonym }

      specify do
        expect(described_class[type: 'Family', valid_only: true]).to match_array [valid]
        expect(described_class[type: 'Family', valid_only: false]).to match_array [valid, synonym]
      end
    end

    describe "searching for taxa with history items" do
      let!(:with_history) { create :family, :with_history_item }

      before do
        create :family # Without history.
      end

      specify do
        expect(described_class[type: 'Family', must_have_history_items: true]).to match_array [with_history]
      end
    end

    describe "searching by year" do
      let!(:taxon) { create :subfamily }

      before do
        reference = create :article_reference, citation_year: '1977'
        taxon.protonym.authorship.update!(reference: reference)
      end

      specify do
        expect(described_class[year: "1977"]).to match_array [taxon]
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
        specify { expect(described_class[protonym: ' Formica fusca ']).to match_array [taxon] }
      end
    end

    describe "searching by ranks" do
      let!(:subfamily) { create :subfamily }

      specify do
        expect(described_class[type: 'Subfamily']).to match_array [subfamily]
      end
    end

    describe "searching by name" do
      let!(:f_fusca) { create :species, name_string: 'Formica fusca' }
      let!(:f_fusca_rufa) { create :subspecies, name_string: 'Formica fusca rufa' }
      let!(:l_fusca) { create :species, name_string: 'Lasius fusca' }

      specify do
        expect(described_class[name: 'fusca', name_search_type: 'contains']).
          to match_array [f_fusca, f_fusca_rufa, l_fusca]
      end

      specify do
        expect(described_class[name: 'Formica fusca', name_search_type: 'matches']).
          to match_array [f_fusca]
      end

      specify do
        expect(described_class[name: 'Formica fusca', name_search_type: 'begins_with']).
          to match_array [f_fusca, f_fusca_rufa]
      end

      context 'when query contains redundant spacing' do
        specify { expect(described_class[name: ' Lasius fusca ']).to match_array [l_fusca] }
      end
    end

    describe "searching by epithet" do
      let!(:taxon) { create :species, name_string: 'Lasius niger' }

      it 'only considers exact matches' do
        expect(described_class[epithet: 'niger']).to eq [taxon]
        expect(described_class[epithet: 'nige']).to eq []
      end

      context 'when query contains redundant spacing' do
        specify { expect(described_class[epithet: ' niger ']).to match_array [taxon] }
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
        specify { expect(described_class[genus: ' Lasius ']).to match_array [taxon] }
      end
    end

    describe "searching by author name" do
      it "finds the taxa for the author's references that are part of citations in the protonym" do
        reference = create :reference,
          author_names: [create(:author_name, name: 'Bolton'), create(:author_name, name: 'Fisher')]
        taxon = create :family
        taxon.protonym.authorship.update!(reference: reference)

        expect(described_class[author_name: 'Fisher']).to eq [taxon]
      end

      describe "when author in protonym has many different names" do
        let!(:barry_taxon) { create :genus }
        let!(:bolton_taxon) { create :genus }
        let!(:author) { create :author }
        let!(:bolton_reference) do
          create :reference, author_names: [create(:author_name, name: 'Bolton', author: author)]
        end
        let!(:barry_reference) do
          create :reference, author_names: [create(:author_name, name: 'Barry', author: author)]
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
        expect(described_class[incertae_sedis_in: 'family']).to eq [taxon]
        expect(described_class[incertae_sedis_in: 'subfamily']).to eq []
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
        create :species, protonym: create(:protonym, biogeographic_region: 'Australasia')
        indomanayan_species = create :species, protonym: create(:protonym, biogeographic_region: 'Indomalaya')
        no_region_species = create :species

        expect(described_class[biogeographic_region: 'Indomalaya']).to eq [indomanayan_species]
        expect(described_class[type: 'Species', biogeographic_region: 'None']).to eq [no_region_species]
      end
    end

    describe "searching type fields" do
      let!(:one) { create :species, protonym: create(:protonym, primary_type_information_taxt: 'one') }
      let!(:two) { create :species, protonym: create(:protonym, secondary_type_information_taxt: 'one two') }
      let!(:three) { create :species, protonym: create(:protonym, type_notes_taxt: 'one two three') }

      before { create :species, protonym: create(:protonym, primary_type_information_taxt: 'unrelated') }

      it "returns taxa with type fields matching the query" do
        expect(described_class[type_information: 'one']).to match_array [one, two, three]
        expect(described_class[type_information: 'two']).to match_array [two, three]
        expect(described_class[type_information: 'three']).to match_array [three]
      end
    end

    describe "searching for forms" do
      it "only returns taxa with those forms" do
        protonym = create :protonym, authorship: create(:citation, forms: 'w.q.')
        atta = create :species, protonym: protonym

        protonym = create :protonym, authorship: create(:citation, forms: 'q.')
        create :species, protonym: protonym

        expect(described_class[forms: 'w.']).to eq [atta]
      end
    end

    describe "searching by status" do
      let!(:valid) { create :family, :valid }
      let!(:synonym) { create :family, :synonym }

      specify do
        expect(described_class[status: 'valid']).to match_array [valid]
        expect(described_class[status: 'homonym']).to be_empty

        # The dummy is incluced or we end end up defaulting to `Taxon.none`.
        expect(described_class[status: "", dummy: "x"]).to match_array [valid, synonym]
        expect(described_class[status: ""]).to be_empty
      end
    end

    describe "searching by fossil" do
      let!(:extant) { create :family }
      let!(:fossil) { create :family, :fossil }

      specify { expect(described_class[fossil: "", dummy: "x"]).to match_array [extant, fossil] }
      specify { expect(described_class[fossil: "true"]).to match_array [fossil] }
      specify { expect(described_class[fossil: "false"]).to match_array [extant] }
    end

    describe "searching by nomen nudum" do
      let!(:no_match) { create :family }
      let!(:yes_match) { create :family, :unavailable, nomen_nudum: true }

      specify { expect(described_class[nomen_nudum: "", dummy: "x"]).to match_array [no_match, yes_match] }
      specify { expect(described_class[nomen_nudum: "true"]).to match_array [yes_match] }
      specify { expect(described_class[nomen_nudum: "false"]).to match_array [no_match] }
    end

    describe "searching by unresolved junior homonym" do
      let!(:no_match) { create :family }
      let!(:yes_match) { create :family, unresolved_homonym: true }

      specify { expect(described_class[unresolved_homonym: "", dummy: "x"]).to match_array [no_match, yes_match] }
      specify { expect(described_class[unresolved_homonym: "true"]).to match_array [yes_match] }
      specify { expect(described_class[unresolved_homonym: "false"]).to match_array [no_match] }
    end

    describe "searching by ichnotaxon" do
      let!(:no_match) { create :family }
      let!(:yes_match) { create :family, :fossil, ichnotaxon: true }

      specify { expect(described_class[ichnotaxon: "", dummy: "x"]).to match_array [no_match, yes_match] }
      specify { expect(described_class[ichnotaxon: "true"]).to match_array [yes_match] }
      specify { expect(described_class[ichnotaxon: "false"]).to match_array [no_match] }
    end

    describe "searching by Hong" do
      let!(:no_match) { create :family }
      let!(:yes_match) { create :family, hong: true }

      specify { expect(described_class[hong: "", dummy: "x"]).to match_array [no_match, yes_match] }
      specify { expect(described_class[hong: "true"]).to match_array [yes_match] }
      specify { expect(described_class[hong: "false"]).to match_array [no_match] }
    end

    describe "searching by collective group name" do
      let!(:no_match) { create :family }
      let!(:yes_match) { create :family, :fossil, collective_group_name: true }

      specify { expect(described_class[collective_group_name: "", dummy: "x"]).to match_array [no_match, yes_match] }
      specify { expect(described_class[collective_group_name: "true"]).to match_array [yes_match] }
      specify { expect(described_class[collective_group_name: "false"]).to match_array [no_match] }
    end
  end
end
