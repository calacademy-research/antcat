# TODO cleanup after extracting into service object.

require "spec_helper"

describe Taxa::AdvancedSearch do
  describe "#call" do
    context "when no meaningful search parameters are given" do
      it "returns an empty array" do
        expect(described_class.new(year: '').call).to eq []
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
          results = described_class.new(rank: 'Genus', year: "1977", valid_only: true).call
          expect(results.map(&:id)).to match_array [atta.id, betta.id]
        end

        it "honors the validity flag" do
          delta = create_genus
          delta.protonym.authorship.update! reference: reference1977
          delta.update! status: 'synonym'

          results = described_class.new(rank: 'Genus', year: "1977", valid_only: true).call
          expect(results.map(&:id)).to match_array [atta.id, betta.id]
        end
      end

      it "returns all regardless of validity if that flag is false" do
        reference1977 = reference_factory author_name: 'Bolton', citation_year: '1977'
        atta = create_genus
        atta.protonym.authorship.update! reference: reference1977
        atta.update! status: 'synonym'

        results = described_class.new(rank: 'Genus', year: "1977", valid_only: false).call
        expect(results.map(&:id)).to match_array [atta.id]
      end

      describe "Finding certain ranks" do
        let!(:subfamily) { create_subfamily }
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
          expect(described_class.new(rank: 'Subfamily', year: "1977").call.map(&:id)).to match_array [subfamily.id]
          expect(described_class.new(rank: 'Tribe', year: "1977").call.map(&:id)).to match_array [tribe.id]
          expect(described_class.new(rank: 'Genus', year: "1977").call.map(&:id)).to match_array [genus.id]
          expect(described_class.new(rank: 'Subgenus', year: "1977").call.map(&:id)).to match_array [subgenus.id]
          expect(described_class.new(rank: 'Species', year: "1977").call.map(&:id)).to match_array [species.id]
          expect(described_class.new(rank: 'Subspecies', year: "1977").call.map(&:id)).to match_array [subspecies.id]
        end

        it "returns just the requested rank, even without any other parameters" do
          expect(described_class.new(rank: 'Subfamily').call.map(&:id)).to match_array [subfamily.id]
          expect(described_class.new(rank: 'Tribe').call.map(&:id)).to match_array [tribe.id]
          expect(described_class.new(rank: 'Genus').call.map(&:id)).to match_array [genus.id]
          expect(described_class.new(rank: 'Subgenus').call.map(&:id)).to match_array [subgenus.id]
          expect(described_class.new(rank: 'Species').call.map(&:id)).to match_array [species.id]
          expect(described_class.new(rank: 'Subspecies').call.map(&:id)).to match_array [subspecies.id]
        end
      end
    end

    describe "Finding by author name" do
      it "finds the taxa for the author's references that are part of citations in the protonym" do
        reference = reference_factory author_name: 'Bolton', citation_year: '1977'
        atta = create_genus
        atta.protonym.authorship.update! reference: reference

        results = described_class.new(rank: 'All', author_name: 'Bolton').call
        expect(results.map(&:id)).to eq [atta.id]
      end

      it "finds the taxa for the author's references, even if he's not the principal author" do
        reference = create :article_reference,
          author_names: [ create(:author_name, name: 'Bolton'),
                          create(:author_name, name: 'Fisher') ],
          citation_year: '1977'
        atta = create_genus
        atta.protonym.authorship.update! reference: reference

        results = described_class.new(rank: 'All', author_name: 'Fisher').call
        expect(results.map(&:id)).to eq [atta.id]
      end

      it "doesn't crash if the author isn't found" do
        reference = create :article_reference,
          author_names: [create(:author_name, name: 'Bolton')],
          citation_year: '1977'
        atta = create_genus
        atta.protonym.authorship.update! reference: reference

        results = described_class.new(rank: 'All', author_name: 'Fisher').call
        expect(results).to be_empty
      end

      it "finds the taxa for the author's references, even if he's nested inside the reference" do
        nested_in = create :article_reference,
          author_names: [create(:author_name, name: 'Bolton')],
          year: "2010"
        reference = NestedReference.new title: 'Ants',
          author_names: [create(:author_name, name: 'Fisher')],
          year: "2011",
          nesting_reference: nested_in,
          pages_in: 'Pp 2 in:'
        atta = create_genus
        atta.protonym.authorship.update! reference: reference

        fisher_results = described_class.new(rank: 'All', author_name: 'Fisher').call
        expect(fisher_results.map(&:id)).to eq [atta.id]

        bolton_results = described_class.new(rank: 'All', author_name: 'Bolton').call
        expect(bolton_results.map(&:id)).to be_empty
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
          results = described_class.new(rank: 'All', author_name: 'Bolton').call
          expect(results.map(&:name_cache)).to match_array [barry_atta.name_cache, bolton_atta.name_cache]
        end

        it "handles year + author name" do
          bolton_reference.citation_year = 1987
          bolton_reference.save!

          results = described_class.new(rank: 'All', author_name: 'Bolton', year: "1987").call
          expect(results.map(&:name_cache)).to match_array [bolton_atta.name_cache]
        end
      end
    end

    describe "Searching for locality" do
      let!(:indonesia) { create :protonym, locality: 'Indonesia (Bhutan)' }
      let!(:china) { create :protonym, locality: 'China' }
      let!(:atta) { create_genus protonym: indonesia }
      let!(:eciton) { create_genus protonym: china }

      it "only returns taxa with that locality" do
        results = described_class.new(rank: 'All', locality: 'Indonesia').call
        expect(results.map(&:id)).to eq [atta.id]
      end

      it "returns taxa with search term at the beginning" do
        results = described_class.new(rank: 'All', locality: 'Indonesia').call
        expect(results.map(&:id)).to eq [atta.id]
      end
    end

    describe "Searching for verbatim type locality" do
      let!(:eciton) { create_species verbatim_type_locality: 'San Pedro' }
      let!(:indonesian_ant) { create_species verbatim_type_locality: 'Indonesia' }

      it "only returns taxa with that verbatim_type_locality" do
        results = described_class.new(rank: 'All', verbatim_type_locality: 'San Pedro').call
        expect(results.map(&:id)).to eq [eciton.id]
      end

      context "when no taxa has that verbatim_type_locality" do
        it "returns nothing" do
          results = described_class.new(rank: 'All', verbatim_type_locality: 'The Bronx').call
          expect(results.map(&:id)).to eq []
        end
      end

      it "matches substrings" do
        results = described_class.new(rank: 'All', verbatim_type_locality: 'Pedro').call
        expect(results.map(&:id)).to eq [eciton.id]
      end
    end

    describe "Searching for type specimen repository" do
      it "only returns taxa with that type specimen repository" do
        create_species type_specimen_repository: 'IDD'
        eciton = create_species type_specimen_repository: 'DDI'

        results = described_class.new(rank: 'All', type_specimen_repository: 'DDI').call
        expect(results.map(&:id)).to eq [eciton.id]
      end

      it "returns nothing if nothing has that type_specimen_repository" do
        create_species

        results = described_class.new(rank: 'All', type_specimen_repository: 'ISC').call
        expect(results.map(&:id)).to eq []
      end

      it "matches substrings" do
        create_species type_specimen_repository: 'III'
        eciton = create_species type_specimen_repository: 'ABCD'

        results = described_class.new(rank: 'All', type_specimen_repository: 'BC').call
        expect(results.map(&:id)).to eq [eciton.id]
      end
    end

    describe "Searching for type specimen code" do
      it "only returns taxa with that type specimen code" do
        create_species type_specimen_code: 'IDD'
        eciton = create_species type_specimen_code: 'DDI'

        results = described_class.new(rank: 'All', type_specimen_code: 'DDI').call
        expect(results.map(&:id)).to eq [eciton.id]
      end

      it "returns nothing if nothing has that type_specimen_code" do
        create_species

        results = described_class.new(rank: 'All', type_specimen_code: 'ISC').call
        expect(results.map(&:id)).to eq []
      end

      it "matches substrings" do
        create_species type_specimen_code: 'III'
        eciton = create_species type_specimen_code: 'ABCD'

        results = described_class.new(rank: 'All', type_specimen_code: 'BC').call
        expect(results.map(&:id)).to eq [eciton.id]
      end
    end

    describe "Searching for biogeographic region" do
      it "only returns taxa with that biogeographic_region" do
        create_species biogeographic_region: 'Australasia'
        eciton = create_species biogeographic_region: 'Indomalaya'

        results = described_class.new(rank: 'All', biogeographic_region: 'Indomalaya').call
        expect(results.map(&:id)).to eq [eciton.id]
      end

      it "not only returns anything if nothing has that biogeographic_region" do
        create_species

        results = described_class.new(rank: 'All', biogeographic_region: 'San Pedro').call
        expect(results.map(&:id)).to eq []
      end

      it "only returns taxa with no biogeographic_region if that's what's specified" do
        create_species biogeographic_region: 'Australasia'
        eciton = create_species

        results = described_class.new(rank: 'Species', biogeographic_region: 'None').call
        expect(results.map(&:id)).to eq [eciton.id]
      end

      it "doesn't match substrings" do
        atta = create_species biogeographic_region: 'Australasia'

        results = described_class.new(rank: 'All', biogeographic_region: 'Aust').call
        expect(results.map(&:id)).not_to eq [atta.id]
      end
    end

    describe "Searching for forms" do
      it "only returns taxa with those forms" do
        citation = create :citation, forms: 'w.q.'
        protonym = create :protonym, authorship: citation
        atta = create_species protonym: protonym

        citation = create :citation, forms: 'q.'
        protonym = create :protonym, authorship: citation
        eciton = create_species protonym: protonym

        results = described_class.new(rank: 'All', forms: 'w.').call
        expect(results.map(&:id)).to eq [atta.id]
      end

      it "returns nothing if nothing has those forms" do
        atta = create_species

        results = described_class.new(rank: 'All', forms: 'w.').call
        expect(results.map(&:id)).to eq []
      end
    end
  end
end
