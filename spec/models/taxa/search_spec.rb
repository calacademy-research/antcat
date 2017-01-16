require 'spec_helper'

describe Taxon do
  describe ".quick_search" do
    let!(:rufa) do
      create :species,
        genus: create(:genus, name: create(:genus_name, name: 'Monoceros')),
        name: create(:species_name, name: 'Monoceros rufa', epithet: 'rufa')
    end
    before { create :genus, name: create(:genus_name, name: 'Monomorium') }

    it "returns [] if nothing matches" do
      results = Taxa::Search.quick_search 'sdfsdf'
      expect(results).to eq []
    end

    it "returns exact matches" do
      results = Taxa::Search.quick_search 'Monomorium'
      expect(results.first.name.to_s).to eq 'Monomorium'
    end

    it "can search by prefix" do
      results = Taxa::Search.quick_search 'Monomor', search_type: 'beginning_with'
      expect(results.first.name.to_s).to eq 'Monomorium'
    end

    it "matches substrings" do
      results = Taxa::Search.quick_search 'iu', search_type: 'containing'
      expect(results.first.name.to_s).to eq 'Monomorium'
    end

    it "returns multiple matches" do
      results = Taxa::Search.quick_search 'Mono', search_type: 'containing'
      expect(results.size).to eq 2
    end

    it "only returns subfamilies, tribes, genera, subgenera, species, and subspecies" do
      create_subfamily 'Lepto'
      create_tribe 'Lepto1'
      create_genus 'Lepto2'
      create_subgenus 'Lepto3'
      create_species 'Lepto4'
      create_subspecies 'Lepto5'

      results = Taxa::Search.quick_search 'Lepto', search_type: 'beginning_with'
      expect(results.size).to eq 6
    end

    it "sorts results by name" do
      %w(Lepti Lepta Lepte).each do |name|
        create :subfamily, name: create(:name, name: name)
      end

      results = Taxa::Search.quick_search 'Lept', search_type: 'beginning_with'
      expect(results.map(&:name).map(&:to_s)).to eq ['Lepta', 'Lepte', 'Lepti']
    end

    describe "Finding full species name" do
      it "searches for full species names" do
        results = Taxa::Search.quick_search 'Monoceros rufa '
        expect(results.first).to eq rufa
      end

      it "searches for whole names, even when using beginning with, even with trailing space" do
        results = Taxa::Search.quick_search 'Monoceros rufa ', search_type: 'beginning_with'
        expect(results.first).to eq rufa
      end

      it "searches for partial species names" do
        results = Taxa::Search.quick_search 'Monoceros ruf', search_type: 'beginning_with'
        expect(results.first).to eq rufa
      end
    end
  end

  describe "#advanced_search" do
    context "when no meaningful search parameters are given" do
      it "returns an empty array" do
        expect(Taxa::Search.advanced_search(year: '')).to eq []
      end
    end

    describe "Rank first described in given year" do
      describe "shared setup..." do
        before do
          @reference1977 = reference_factory author_name: 'Bolton', citation_year: '1977'
          reference1988 = reference_factory author_name: 'Fisher', citation_year: '1988'
          @atta = create_genus
          @atta.protonym.authorship.update! reference: @reference1977
          @betta = create_genus
          @betta.protonym.authorship.update! reference: @reference1977
          gamma = create_genus
          gamma.protonym.authorship.update! reference: reference1988
        end

        it "returns the one match" do
          results = Taxa::Search.advanced_search rank: 'Genus', year: "1977", valid_only: true
          expect(results.map(&:id)).to match_array [@atta.id, @betta.id]
        end

        it "honors the validity flag" do
          delta = create_genus
          delta.protonym.authorship.update! reference: @reference1977
          delta.update! status: 'synonym'

          results = Taxa::Search.advanced_search rank: 'Genus', year: "1977", valid_only: true
          expect(results.map(&:id)).to match_array [@atta.id, @betta.id]
        end
      end

      it "returns all regardless of validity if that flag is false" do
        reference1977 = reference_factory author_name: 'Bolton', citation_year: '1977'
        atta = create_genus
        atta.protonym.authorship.update! reference: reference1977
        atta.update! status: 'synonym'

        results = Taxa::Search.advanced_search rank: 'Genus', year: "1977", valid_only: false
        expect(results.map(&:id)).to match_array [atta.id]
      end

      describe "Finding certain ranks" do
        before do
          taxa = []
          taxa << @subfamily = create_subfamily
          taxa << @tribe = create_tribe(subfamily: @subfamily)
          taxa << @genus = create_genus(tribe: @tribe)
          taxa << @subgenus = create_subgenus(genus: @genus)
          taxa << @species = create_species(genus: @genus)
          taxa << @subspecies = create_subspecies('Atta major minor', species: @species, genus: @genus)
          reference = reference_factory author_name: 'Bolton', citation_year: '1977'
          taxa.each do |taxon|
            taxon.protonym.authorship.update! reference: reference
          end
        end

        it "returns just the requested rank, if asked" do
          expect(Taxa::Search.advanced_search(rank: 'Subfamily', year: "1977").map(&:id)).to match_array [@subfamily.id]
          expect(Taxa::Search.advanced_search(rank: 'Tribe', year: "1977").map(&:id)).to match_array [@tribe.id]
          expect(Taxa::Search.advanced_search(rank: 'Genus', year: "1977").map(&:id)).to match_array [@genus.id]
          expect(Taxa::Search.advanced_search(rank: 'Subgenus', year: "1977").map(&:id)).to match_array [@subgenus.id]
          expect(Taxa::Search.advanced_search(rank: 'Species', year: "1977").map(&:id)).to match_array [@species.id]
          expect(Taxa::Search.advanced_search(rank: 'Subspecies', year: "1977").map(&:id)).to match_array [@subspecies.id]
        end

        it "returns just the requested rank, even without any other parameters" do
          expect(Taxa::Search.advanced_search(rank: 'Subfamily').map(&:id)).to match_array [@subfamily.id]
          expect(Taxa::Search.advanced_search(rank: 'Tribe').map(&:id)).to match_array [@tribe.id]
          expect(Taxa::Search.advanced_search(rank: 'Genus').map(&:id)).to match_array [@genus.id]
          expect(Taxa::Search.advanced_search(rank: 'Subgenus').map(&:id)).to match_array [@subgenus.id]
          expect(Taxa::Search.advanced_search(rank: 'Species').map(&:id)).to match_array [@species.id]
          expect(Taxa::Search.advanced_search(rank: 'Subspecies').map(&:id)).to match_array [@subspecies.id]
        end
      end
    end

    describe "Finding by author name" do
      it "finds the taxa for the author's references that are part of citations in the protonym" do
        reference = reference_factory author_name: 'Bolton', citation_year: '1977'
        atta = create_genus
        atta.protonym.authorship.update! reference: reference

        results = Taxa::Search.advanced_search rank: 'All', author_name: 'Bolton'
        expect(results.map(&:id)).to eq [atta.id]
      end

      it "finds the taxa for the author's references, even if he's not the principal author" do
        reference = create :article_reference,
          author_names: [ create(:author_name, name: 'Bolton'),
                          create(:author_name, name: 'Fisher') ],
          citation_year: '1977'
        atta = create_genus
        atta.protonym.authorship.update! reference: reference

        results = Taxa::Search.advanced_search rank: 'All', author_name: 'Fisher'
        expect(results.map(&:id)).to eq [atta.id]
      end

      it "doesn't crash if the author isn't found" do
        reference = create :article_reference,
          author_names: [create(:author_name, name: 'Bolton')],
          citation_year: '1977'
        atta = create_genus
        atta.protonym.authorship.update! reference: reference

        results = Taxa::Search.advanced_search rank: 'All', author_name: 'Fisher'
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

        fisher_results = Taxa::Search.advanced_search rank: 'All', author_name: 'Fisher'
        expect(fisher_results.map(&:id)).to eq [atta.id]

        bolton_results = Taxa::Search.advanced_search rank: 'All', author_name: 'Bolton'
        expect(bolton_results.map(&:id)).to be_empty
      end

      describe "shared setup..." do
        before do
          barry_bolton = create :author
          barry = create :author_name, name: 'Barry', author: barry_bolton
          bolton = create :author_name, name: 'Bolton', author: barry_bolton

          barry_reference = create :article_reference, author_names: [barry], citation_year: '1977'
          @barry_atta = create_genus 'Barry_Atta'
          @barry_atta.protonym.authorship.update! reference: barry_reference

          @bolton_reference = create :article_reference, author_names: [bolton], citation_year: '1977'
          @bolton_atta = create_genus 'Bolton_Atta'
          @bolton_atta.protonym.authorship.update! reference: @bolton_reference
        end

        it "finds the taxa for the author's references that are part of citations in the protonym, even under different names" do
          results = Taxa::Search.advanced_search rank: 'All', author_name: 'Bolton'
          expect(results.map(&:name_cache)).to match_array [@barry_atta.name_cache, @bolton_atta.name_cache]
        end

        it "handles year + author name" do
          @bolton_reference.citation_year = 1987
          @bolton_reference.save!

          results = Taxa::Search.advanced_search rank: 'All', author_name: 'Bolton', year: "1987"
          expect(results.map(&:name_cache)).to match_array [@bolton_atta.name_cache]
        end
      end
    end

    describe "Searching for locality" do
      let!(:indonesia) { create :protonym, locality: 'Indonesia (Bhutan)' }
      let!(:china) { create :protonym, locality: 'China' }
      let!(:atta) { create_genus protonym: indonesia }
      let!(:eciton) { create_genus protonym: china }

      it "only returns taxa with that locality" do
        results = Taxa::Search.advanced_search rank: 'All', locality: 'Indonesia'
        expect(results.map(&:id)).to eq [atta.id]
      end

      it "returns taxa with search term at the beginning" do
        results = Taxa::Search.advanced_search rank: 'All', locality: 'Indonesia'
        expect(results.map(&:id)).to eq [atta.id]
      end
    end

    describe "Searching for verbatim type locality" do
      let!(:eciton) { create_species verbatim_type_locality: 'San Pedro' }
      let!(:indonesian_ant) { create_species verbatim_type_locality: 'Indonesia' }

      it "only returns taxa with that verbatim_type_locality" do
        results = Taxa::Search.advanced_search rank: 'All', verbatim_type_locality: 'San Pedro'
        expect(results.map(&:id)).to eq [eciton.id]
      end

      context "when no taxa has that verbatim_type_locality" do
        it "returns nothing" do
          results = Taxa::Search.advanced_search rank: 'All', verbatim_type_locality: 'The Bronx'
          expect(results.map(&:id)).to eq []
        end
      end

      it "matches substrings" do
        results = Taxa::Search.advanced_search rank: 'All', verbatim_type_locality: 'Pedro'
        expect(results.map(&:id)).to eq [eciton.id]
      end
    end

    describe "Searching for type specimen repository" do
      it "only returns taxa with that type specimen repository" do
        create_species type_specimen_repository: 'IDD'
        eciton = create_species type_specimen_repository: 'DDI'

        results = Taxa::Search.advanced_search rank: 'All', type_specimen_repository: 'DDI'
        expect(results.map(&:id)).to eq [eciton.id]
      end

      it "returns nothing if nothing has that type_specimen_repository" do
        create_species

        results = Taxa::Search.advanced_search rank: 'All', type_specimen_repository: 'ISC'
        expect(results.map(&:id)).to eq []
      end

      it "matches substrings" do
        create_species type_specimen_repository: 'III'
        eciton = create_species type_specimen_repository: 'ABCD'

        results = Taxa::Search.advanced_search rank: 'All', type_specimen_repository: 'BC'
        expect(results.map(&:id)).to eq [eciton.id]
      end
    end

    describe "Searching for type specimen code" do
      it "only returns taxa with that type specimen code" do
        create_species type_specimen_code: 'IDD'
        eciton = create_species type_specimen_code: 'DDI'

        results = Taxa::Search.advanced_search rank: 'All', type_specimen_code: 'DDI'
        expect(results.map(&:id)).to eq [eciton.id]
      end

      it "returns nothing if nothing has that type_specimen_code" do
        create_species

        results = Taxa::Search.advanced_search rank: 'All', type_specimen_code: 'ISC'
        expect(results.map(&:id)).to eq []
      end

      it "matches substrings" do
        create_species type_specimen_code: 'III'
        eciton = create_species type_specimen_code: 'ABCD'

        results = Taxa::Search.advanced_search rank: 'All', type_specimen_code: 'BC'
        expect(results.map(&:id)).to eq [eciton.id]
      end
    end

    describe "Searching for biogeographic region" do
      it "only returns taxa with that biogeographic_region" do
        create_species biogeographic_region: 'Australasia'
        eciton = create_species biogeographic_region: 'Indomalaya'

        results = Taxa::Search.advanced_search rank: 'All', biogeographic_region: 'Indomalaya'
        expect(results.map(&:id)).to eq [eciton.id]
      end

      it "not only returns anything if nothing has that biogeographic_region" do
        create_species

        results = Taxa::Search.advanced_search rank: 'All', biogeographic_region: 'San Pedro'
        expect(results.map(&:id)).to eq []
      end

      it "only returns taxa with no biogeographic_region if that's what's specified" do
        create_species biogeographic_region: 'Australasia'
        eciton = create_species

        results = Taxa::Search.advanced_search rank: 'Species', biogeographic_region: 'None'
        expect(results.map(&:id)).to eq [eciton.id]
      end

      it "doesn't match substrings" do
        atta = create_species biogeographic_region: 'Australasia'

        results = Taxa::Search.advanced_search rank: 'All', biogeographic_region: 'Aust'
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

        results = Taxa::Search.advanced_search rank: 'All', forms: 'w.'
        expect(results.map(&:id)).to eq [atta.id]
      end

      it "returns nothing if nothing has those forms" do
        atta = create_species

        results = Taxa::Search.advanced_search rank: 'All', forms: 'w.'
        expect(results.map(&:id)).to eq []
      end
    end
  end
end
