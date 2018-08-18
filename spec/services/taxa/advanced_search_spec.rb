# TODO cleanup after extracting into service object.

require "spec_helper"

describe Taxa::AdvancedSearch do
  describe "#call" do
    context "when no meaningful search parameters are given" do
      it "returns an empty array" do
        expect(described_class[year: '']).to be_empty
      end
    end

    describe "Rank first described in given year" do
      describe "shared setup..." do
        let!(:reference1977) { reference_factory author_name: 'Bolton', citation_year: '1977' }
        let!(:atta) { create_genus }
        let!(:betta) { create_genus }

        before do
          atta.protonym.authorship.update! reference: reference1977
          betta.protonym.authorship.update! reference: reference1977
          reference1988 = reference_factory author_name: 'Fisher', citation_year: '1988'
          gamma = create_genus
          gamma.protonym.authorship.update! reference: reference1988
        end

        it "returns the one match" do
          results = described_class[rank: 'Genus', year: "1977", valid_only: true]
          expect(results).to match_array [atta, betta]
        end

        it "honors the validity flag" do
          delta = create_genus
          delta.protonym.authorship.update! reference: reference1977
          delta.update! status: Status::SYNONYM

          results = described_class[rank: 'Genus', year: "1977", valid_only: true]
          expect(results).to match_array [atta, betta]
        end
      end

      it "returns all regardless of validity if that flag is false" do
        reference1977 = reference_factory author_name: 'Bolton', citation_year: '1977'
        atta = create_genus
        atta.protonym.authorship.update! reference: reference1977
        atta.update! status: Status::SYNONYM

        results = described_class[rank: 'Genus', year: "1977", valid_only: false]
        expect(results).to match_array [atta]
      end

      describe "Finding certain ranks" do
        let!(:subfamily) { create(:subfamily) }
        let!(:tribe) { create_tribe subfamily: subfamily }
        let!(:genus) { create_genus tribe: tribe }
        let!(:subgenus) { create_subgenus genus: genus }
        let!(:species) { create_species genus: genus }
        let!(:subspecies) { create_subspecies 'Atta major minor', species: species, genus: genus }

        before do
          reference = reference_factory author_name: 'Bolton', citation_year: '1977'
          [subfamily, tribe, genus, subgenus, species, subspecies].each do |taxon|
            taxon.protonym.authorship.update! reference: reference
          end
        end

        it "returns just the requested rank, if asked" do
          expect(described_class[rank: 'Subfamily', year: "1977"]).to match_array [subfamily]
          expect(described_class[rank: 'Tribe', year: "1977"]).to match_array [tribe]
          expect(described_class[rank: 'Genus', year: "1977"]).to match_array [genus]
          expect(described_class[rank: 'Subgenus', year: "1977"]).to match_array [subgenus]
          expect(described_class[rank: 'Species', year: "1977"]).to match_array [species]
          expect(described_class[rank: 'Subspecies', year: "1977"]).to match_array [subspecies]
        end

        it "returns just the requested rank, even without any other parameters" do
          expect(described_class[rank: 'Subfamily']).to match_array [subfamily]
          expect(described_class[rank: 'Tribe']).to match_array [tribe]
          expect(described_class[rank: 'Genus']).to match_array [genus]
          expect(described_class[rank: 'Subgenus']).to match_array [subgenus]
          expect(described_class[rank: 'Species']).to match_array [species]
          expect(described_class[rank: 'Subspecies']).to match_array [subspecies]
        end
      end
    end

    describe "Finding by author name" do
      it "finds the taxa for the author's references that are part of citations in the protonym" do
        reference = reference_factory author_name: 'Bolton'
        atta = create_genus
        atta.protonym.authorship.update! reference: reference

        expect(described_class[author_name: 'Bolton']).to eq [atta]
      end

      it "finds the taxa for the author's references, even if he's not the principal author" do
        reference = create :article_reference,
          author_names: [create(:author_name, name: 'Bolton'), create(:author_name, name: 'Fisher')]
        atta = create_genus
        atta.protonym.authorship.update! reference: reference

        expect(described_class[author_name: 'Fisher']).to eq [atta]
      end

      it "doesn't crash if the author isn't found" do
        reference = create :article_reference,
          author_names: [create(:author_name, name: 'Bolton')]
        atta = create_genus
        atta.protonym.authorship.update! reference: reference

        expect(described_class[author_name: 'Fisher']).to be_empty
      end

      it "finds the taxa for the author's references, even if he's nested inside the reference" do
        nested_in = create :article_reference,
          author_names: [create(:author_name, name: 'Bolton')]
        reference = create :nested_reference, title: 'Ants',
          author_names: [create(:author_name, name: 'Fisher')],
          nesting_reference: nested_in
        atta = create_genus
        atta.protonym.authorship.update! reference: reference

        expect(described_class[author_name: 'Fisher']).to eq [atta]
        expect(described_class[author_name: 'Bolton']).to be_empty
      end

      describe "shared setup..." do
        let!(:barry_atta) { create_genus 'Barry_Atta' }
        let!(:bolton_atta) { create_genus 'Bolton_Atta' }
        let!(:barry_bolton) { create :author }
        let!(:bolton_reference) do
          bolton = create :author_name, name: 'Bolton', author: barry_bolton
          create :article_reference, author_names: [bolton], citation_year: '1977'
        end

        before do
          barry = create :author_name, name: 'Barry', author: barry_bolton
          barry_reference = create :article_reference, author_names: [barry], citation_year: '1977'
          barry_atta.protonym.authorship.update! reference: barry_reference
          bolton_atta.protonym.authorship.update! reference: bolton_reference
        end

        it "finds the taxa for the author's references that are part of citations in the protonym, even under different names" do
          results = described_class[author_name: 'Bolton']
          expect(results).to match_array [barry_atta, bolton_atta]
        end

        it "handles year + author name" do
          bolton_reference.citation_year = 1987
          bolton_reference.save!

          results = described_class[author_name: 'Bolton', year: "1987"]
          expect(results).to match_array [bolton_atta]
        end
      end
    end

    describe "Searching for locality" do
      let!(:indonesia) { create :protonym, locality: 'Indonesia (Bhutan)' }
      let!(:china) { create :protonym, locality: 'China' }
      let!(:atta) { create_genus protonym: indonesia }
      let!(:eciton) { create_genus protonym: china }

      it "only returns taxa with that locality" do
        expect(described_class[locality: 'Indonesia']).to eq [atta]
      end
    end

    describe "Searching for biogeographic region" do
      it "only returns taxa with that biogeographic_region" do
        create_species biogeographic_region: 'Australasia'
        eciton = create_species biogeographic_region: 'Indomalaya'

        expect(described_class[biogeographic_region: 'Indomalaya']).to eq [eciton]
      end

      it "not only returns anything if nothing has that biogeographic_region" do
        create_species
        expect(described_class[biogeographic_region: 'San Pedro']).to be_empty
      end

      it "only returns taxa with no biogeographic_region if that's what's specified" do
        create_species biogeographic_region: 'Australasia'
        eciton = create_species

        results = described_class[rank: 'Species', biogeographic_region: 'None']
        expect(results).to eq [eciton]
      end

      it "doesn't match substrings" do
        atta = create_species biogeographic_region: 'Australasia'
        expect(described_class[biogeographic_region: 'Aust']).not_to eq [atta]
      end
    end

    describe "Searching type fields" do
      let!(:one) { create :species, published_type_information: 'one' }
      let!(:two) { create :species, additional_type_information: 'one two' }
      let!(:three) { create :species, type_notes: 'one two three' }

      before { create :species, published_type_information: 'unrelated' }

      it "returns taxa with type fields matching the query" do
        expect(described_class[type_information: 'one']).to match_array [one, two, three]
        expect(described_class[type_information: 'two']).to match_array [two, three]
        expect(described_class[type_information: 'three']).to match_array [three]
      end
    end

    describe "Searching for forms" do
      it "only returns taxa with those forms" do
        citation = create :citation, forms: 'w.q.'
        protonym = create :protonym, authorship: citation
        atta = create_species protonym: protonym

        citation = create :citation, forms: 'q.'
        protonym = create :protonym, authorship: citation
        create_species protonym: protonym # eciton

        expect(described_class[forms: 'w.']).to eq [atta]
      end

      it "returns nothing if nothing has those forms" do
        create_species
        expect(described_class[forms: 'w.']).to be_empty
      end
    end

    describe "Searching by status" do
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

    describe "Searching by fossil" do
      let!(:extant) { create :family }
      let!(:fossil) { create :family, :fossil }

      specify { expect(described_class[fossil: "", dummy: "x"]).to match_array [extant, fossil] }
      specify { expect(described_class[fossil: "true"]).to match_array [fossil] }
      specify { expect(described_class[fossil: "false"]).to match_array [extant] }
    end

    describe "Searching by nomen nudum" do
      let!(:no_match) { create :family }
      let!(:yes_match) { create :family, nomen_nudum: true }

      specify { expect(described_class[nomen_nudum: "", dummy: "x"]).to match_array [no_match, yes_match] }
      specify { expect(described_class[nomen_nudum: "true"]).to match_array [yes_match] }
      specify { expect(described_class[nomen_nudum: "false"]).to match_array [no_match] }
    end

    describe "Searching by unresolved junior homonym" do
      let!(:no_match) { create :family }
      let!(:yes_match) { create :family, unresolved_homonym: true }

      specify { expect(described_class[unresolved_junior_homonym: "", dummy: "x"]).to match_array [no_match, yes_match] }
      specify { expect(described_class[unresolved_junior_homonym: "true"]).to match_array [yes_match] }
      specify { expect(described_class[unresolved_junior_homonym: "false"]).to match_array [no_match] }
    end

    describe "Searching by ichnotaxon" do
      let!(:no_match) { create :family }
      let!(:yes_match) { create :family, ichnotaxon: true }

      specify { expect(described_class[ichnotaxon: "", dummy: "x"]).to match_array [no_match, yes_match] }
      specify { expect(described_class[ichnotaxon: "true"]).to match_array [yes_match] }
      specify { expect(described_class[ichnotaxon: "false"]).to match_array [no_match] }
    end

    describe "Searching by Hong" do
      let!(:no_match) { create :family }
      let!(:yes_match) { create :family, hong: true }

      specify { expect(described_class[hong: "", dummy: "x"]).to match_array [no_match, yes_match] }
      specify { expect(described_class[hong: "true"]).to match_array [yes_match] }
      specify { expect(described_class[hong: "false"]).to match_array [no_match] }
    end
  end
end
