# TODO cleanup after extracting into service object.

require "spec_helper"

describe Taxa::AdvancedSearch do
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

    describe "searching by year" do
      let!(:subfamily) { create :subfamily }
      let!(:another_subfamily) { create :subfamily }

      before do
        reference = create :reference, citation_year: '1977'
        subfamily.protonym.authorship.update! reference: reference
      end

      specify do
        expect(described_class[year: "1977"]).to match_array [subfamily]
        expect(described_class[year: "1979"]).to be_empty
      end
    end

    describe "searching by ranks" do
      let!(:subfamily) { create :subfamily }
      let!(:tribe) { create :tribe, subfamily: subfamily }
      let!(:genus) { create :genus, tribe: tribe }
      let!(:subgenus) { create :subgenus, genus: genus }
      let!(:species) { create :species, genus: genus }
      let!(:subspecies) { create :subspecies, species: species, genus: genus }

      specify do
        expect(described_class[type: 'Subfamily']).to match_array [subfamily]
        expect(described_class[type: 'Tribe']).to match_array [tribe]
        expect(described_class[type: 'Genus']).to match_array [genus]
        expect(described_class[type: 'Subgenus']).to match_array [subgenus]
        expect(described_class[type: 'Species']).to match_array [species]
        expect(described_class[type: 'Subspecies']).to match_array [subspecies]
      end
    end

    describe "searching by author name" do
      it "finds the taxa for the author's references that are part of citations in the protonym" do
        reference = create :reference, author_name: 'Bolton'
        taxon = create :family
        taxon.protonym.authorship.update! reference: reference

        expect(described_class[author_name: 'Bolton']).to eq [taxon]
      end

      it "finds the taxa for the author's references, even if he's not the principal author" do
        reference = create :reference,
          author_names: [create(:author_name, name: 'Bolton'), create(:author_name, name: 'Fisher')]
        taxon = create :family
        taxon.protonym.authorship.update! reference: reference

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
          barry_taxon.protonym.authorship.update! reference: barry_reference
          bolton_taxon.protonym.authorship.update! reference: bolton_reference
        end

        specify do
          expect(described_class[author_name: 'Bolton']).to match_array [barry_taxon, bolton_taxon]
        end
      end
    end

    describe "searching for locality" do
      let!(:indonesia) { create :protonym, locality: 'Indonesia (Bhutan)' }
      let!(:china) { create :protonym, locality: 'China' }
      let!(:atta) { create :genus, protonym: indonesia }
      let!(:eciton) { create :genus, protonym: china }

      it "only returns taxa with that locality" do
        expect(described_class[locality: 'Indonesia']).to eq [atta]
      end
    end

    describe "searching for biogeographic region" do
      it "only returns taxa with that biogeographic_region" do
        create :species, biogeographic_region: 'Australasia'
        indomanayan_species = create :species, biogeographic_region: 'Indomalaya'
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
      let!(:yes_match) { create :family, nomen_nudum: true }

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
      let!(:yes_match) { create :family, ichnotaxon: true }

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
  end
end
