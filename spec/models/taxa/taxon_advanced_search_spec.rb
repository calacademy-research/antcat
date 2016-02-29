require 'spec_helper'

describe Taxon do

  describe "Advanced search" do
    describe "When no meaningful search parameters are given" do
      it "should return an empty array" do
        expect(Taxa::Search.advanced_search({year: ''})).to eq([])
      end
    end
    describe "Rank first described in given year" do
      it "should return the one match" do
        reference1977 = reference_factory author_name: 'Bolton', citation_year: '1977'
        reference1988 = reference_factory author_name: 'Fisher', citation_year: '1988'
        atta = create_genus
        atta.protonym.authorship.update_attributes! reference: reference1977
        betta = create_genus
        betta.protonym.authorship.update_attributes! reference: reference1977
        gamma = create_genus
        gamma.protonym.authorship.update_attributes! reference: reference1988
        expect(Taxa::Search.advanced_search(rank: 'Genus', year: 1977, valid_only: true).map(&:id)).to match_array([atta.id, betta.id])
      end
      it "should honor the validity flag" do
        reference1977 = reference_factory author_name: 'Bolton', citation_year: '1977'
        reference1988 = reference_factory author_name: 'Fisher', citation_year: '1988'
        atta = create_genus
        atta.protonym.authorship.update_attributes! reference: reference1977
        betta = create_genus
        betta.protonym.authorship.update_attributes! reference: reference1977
        gamma = create_genus
        gamma.protonym.authorship.update_attributes! reference: reference1988
        delta = create_genus
        delta.protonym.authorship.update_attributes! reference: reference1977
        delta.update_attributes! status: 'synonym'
        expect(Taxa::Search.advanced_search(rank: 'Genus', year: 1977, valid_only: true).map(&:id)).to match_array([atta.id, betta.id])
      end
      it "should return all regardless of validity if that flag is false" do
        reference1977 = reference_factory author_name: 'Bolton', citation_year: '1977'
        atta = create_genus
        atta.protonym.authorship.update_attributes! reference: reference1977
        atta.update_attributes! status: 'synonym'
        expect(Taxa::Search.advanced_search(rank: 'Genus', year: 1977, valid_only: false).map(&:id)).to match_array([atta.id])
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
            taxon.protonym.authorship.update_attributes! reference: reference
          end
        end

        it "should return just the requested rank, if asked" do
          expect(Taxa::Search.advanced_search(rank: 'Subfamily', year: 1977).map(&:id)).to match_array([@subfamily.id])
          expect(Taxa::Search.advanced_search(rank: 'Tribe', year: 1977).map(&:id)).to match_array([@tribe.id])
          expect(Taxa::Search.advanced_search(rank: 'Genus', year: 1977).map(&:id)).to match_array([@genus.id])
          expect(Taxa::Search.advanced_search(rank: 'Subgenus', year: 1977).map(&:id)).to match_array([@subgenus.id])
          expect(Taxa::Search.advanced_search(rank: 'Species', year: 1977).map(&:id)).to match_array([@species.id])
          expect(Taxa::Search.advanced_search(rank: 'Subspecies', year: 1977).map(&:id)).to match_array([@subspecies.id])
        end

        it "should return just the requested rank, even without any other parameters" do
          expect(Taxa::Search.advanced_search(rank: 'Subfamily').map(&:id)).to match_array([@subfamily.id])
          expect(Taxa::Search.advanced_search(rank: 'Tribe').map(&:id)).to match_array([@tribe.id])
          expect(Taxa::Search.advanced_search(rank: 'Genus').map(&:id)).to match_array([@genus.id])
          expect(Taxa::Search.advanced_search(rank: 'Subgenus').map(&:id)).to match_array([@subgenus.id])
          expect(Taxa::Search.advanced_search(rank: 'Species').map(&:id)).to match_array([@species.id])
          expect(Taxa::Search.advanced_search(rank: 'Subspecies').map(&:id)).to match_array([@subspecies.id])
        end
      end
    end

    describe "Finding by author name" do
      it "should find the taxa for the author's references that are part of citations in the protonym" do
        reference = reference_factory author_name: 'Bolton', citation_year: '1977'
        atta = create_genus
        atta.protonym.authorship.update_attributes! reference: reference
        expect(Taxa::Search.advanced_search(rank: 'All', author_name: 'Bolton').map(&:id)).to eq([atta.id])
      end

      it "should find the taxa for the author's references, even if he's not the principal author" do
        reference = FactoryGirl.create :article_reference, author_names: [FactoryGirl.create(:author_name, name: 'Bolton'), FactoryGirl.create(:author_name, name: 'Fisher')], citation_year: '1977'
        atta = create_genus
        atta.protonym.authorship.update_attributes! reference: reference
        expect(Taxa::Search.advanced_search(rank: 'All', author_name: 'Fisher').map(&:id)).to eq([atta.id])
      end

      it "should not crash if the author isn't found" do
        reference = FactoryGirl.create :article_reference, author_names: [FactoryGirl.create(:author_name, name: 'Bolton')], citation_year: '1977'
        atta = create_genus
        atta.protonym.authorship.update_attributes! reference: reference
        expect(Taxa::Search.advanced_search(rank: 'All', author_name: 'Fisher')).to be_empty
      end

      it "should find the taxa for the author's references, even if he's nested inside the reference" do
        nested_in = FactoryGirl.create :article_reference, author_names: [FactoryGirl.create(:author_name, name: 'Bolton')], year: 2010
        reference = NestedReference.new title: 'Ants', author_names: [FactoryGirl.create(:author_name, name: 'Fisher')], year: 2011, nesting_reference: nested_in, pages_in: 'Pp 2 in:'
        atta = create_genus
        atta.protonym.authorship.update_attributes! reference: reference
        expect(Taxa::Search.advanced_search(rank: 'All', author_name: 'Fisher').map(&:id)).to eq([atta.id])
        expect(Taxa::Search.advanced_search(rank: 'All', author_name: 'Bolton').map(&:id)).to be_empty
      end

      it "should find the taxa for the author's references that are part of citations in the protonym, even under different names" do
        barry_bolton = FactoryGirl.create :author
        barry = FactoryGirl.create :author_name, name: 'Barry', author: barry_bolton
        bolton = FactoryGirl.create :author_name, name: 'Bolton', author: barry_bolton

        barry_reference = FactoryGirl.create :article_reference, author_names: [barry], citation_year: '1977'
        barry_atta = create_genus 'Barry_Atta'
        barry_atta.protonym.authorship.update_attributes! reference: barry_reference

        bolton_reference = FactoryGirl.create :article_reference, author_names: [bolton], citation_year: '1977'
        bolton_atta = create_genus 'Bolton_Atta'
        bolton_atta.protonym.authorship.update_attributes! reference: bolton_reference

        expect(Taxa::Search.advanced_search(rank: 'All', author_name: 'Bolton').map(&:name_cache)).to match_array([barry_atta.name_cache, bolton_atta.name_cache])
      end

      it "should handle year + author name" do
        barry_bolton = FactoryGirl.create :author
        barry = FactoryGirl.create :author_name, name: 'Barry', author: barry_bolton
        bolton = FactoryGirl.create :author_name, name: 'Bolton', author: barry_bolton

        barry_reference = FactoryGirl.create :article_reference, author_names: [barry], citation_year: '1977'
        barry_atta = create_genus 'Barry_Atta'
        barry_atta.protonym.authorship.update_attributes! reference: barry_reference

        bolton_reference = FactoryGirl.create :article_reference, author_names: [bolton], citation_year: '1987'
        bolton_atta = create_genus 'Bolton_Atta'
        bolton_atta.protonym.authorship.update_attributes! reference: bolton_reference

        expect(Taxa::Search.advanced_search(rank: 'All', author_name: 'Bolton', year: 1987).map(&:name_cache)).to match_array([bolton_atta.name_cache])
      end

    end

    describe "Searching for locality" do
      before do
        @indonesia = FactoryGirl.create :protonym, locality: 'Indonesia (Bhutan)'
        @china = FactoryGirl.create :protonym, locality: 'China'
      end
      it "should only return taxa with that locality" do
        atta = create_genus protonym: @indonesia
        eciton = create_genus protonym: @china
        expect(Taxa::Search.advanced_search(rank: 'All', locality: 'Indonesia').map(&:id)).to eq([atta.id])
      end
      it "should return taxa with search term at the beginning" do
        atta = create_genus protonym: @indonesia
        eciton = create_genus protonym: @china
        expect(Taxa::Search.advanced_search(rank: 'All', locality: 'Indonesia').map(&:id)).to eq([atta.id])
      end
    end

    describe "Searching for verbatim type locality" do
      it "should only return taxa with that verbatim_type_locality" do
        atta = create_species verbatim_type_locality: 'Indonesia'
        eciton = create_species verbatim_type_locality: 'San Pedro'
        expect(Taxa::Search.advanced_search(rank: 'All', verbatim_type_locality: 'San Pedro').map(&:id)).to eq([eciton.id])
      end
      it "should not only return anything if nothing has that verbatim_type_locality" do
        atta = create_species
        expect(Taxa::Search.advanced_search(rank: 'All', verbatim_type_locality: 'San Pedro').map(&:id)).to eq([])
      end
      it "should do substring search" do
        atta = create_species verbatim_type_locality: 'Indonesia'
        eciton = create_species verbatim_type_locality: 'San Pedro'
        expect(Taxa::Search.advanced_search(rank: 'All', verbatim_type_locality: 'Pedro').map(&:id)).to eq([eciton.id])
      end
    end

    describe "Searching for type specimen repository" do
      it "should only return taxa with that type specimen repository" do
        atta = create_species type_specimen_repository: 'IDD'
        eciton = create_species type_specimen_repository: 'DDI'
        expect(Taxa::Search.advanced_search(rank: 'All', type_specimen_repository: 'DDI').map(&:id)).to eq([eciton.id])
      end
      it "should return nothing if nothing has that type_specimen_repository" do
        atta = create_species
        expect(Taxa::Search.advanced_search(rank: 'All', type_specimen_repository: 'ISC').map(&:id)).to eq([])
      end
      it "should do substring search" do
        atta = create_species type_specimen_repository: 'III'
        eciton = create_species type_specimen_repository: 'ABCD'
        expect(Taxa::Search.advanced_search(rank: 'All', type_specimen_repository: 'BC').map(&:id)).to eq([eciton.id])
      end
    end

    describe "Searching for type specimen code" do
      it "should only return taxa with that type specimen code" do
        atta = create_species type_specimen_code: 'IDD'
        eciton = create_species type_specimen_code: 'DDI'
        expect(Taxa::Search.advanced_search(rank: 'All', type_specimen_code: 'DDI').map(&:id)).to eq([eciton.id])
      end
      it "should return nothing if nothing has that type_specimen_code" do
        atta = create_species
        expect(Taxa::Search.advanced_search(rank: 'All', type_specimen_code: 'ISC').map(&:id)).to eq([])
      end
      it "should do substring search" do
        atta = create_species type_specimen_code: 'III'
        eciton = create_species type_specimen_code: 'ABCD'
        expect(Taxa::Search.advanced_search(rank: 'All', type_specimen_code: 'BC').map(&:id)).to eq([eciton.id])
      end
    end

    describe "Searching for biogeographic region" do
      it "should only return taxa with that biogeographic_region" do
        atta = create_species biogeographic_region: 'Australasia'
        eciton = create_species biogeographic_region: 'Indomalaya'
        expect(Taxa::Search.advanced_search(rank: 'All', biogeographic_region: 'Indomalaya').map(&:id)).to eq([eciton.id])
      end
      it "should not only return anything if nothing has that biogeographic_region" do
        atta = create_species
        expect(Taxa::Search.advanced_search(rank: 'All', biogeographic_region: 'San Pedro').map(&:id)).to eq([])
      end
      it "should only return taxa with no biogeographic_region if that's what's specified" do
        atta = create_species biogeographic_region: 'Australasia'
        eciton = create_species
        expect(Taxa::Search.advanced_search(rank: 'Species', biogeographic_region: 'None').map(&:id)).to eq([eciton.id])
      end
      it "should not do substring search" do
        atta = create_species biogeographic_region: 'Australasia'
        expect(Taxa::Search.advanced_search(rank: 'All', biogeographic_region: 'Aust').map(&:id)).not_to eq([atta.id])
      end
    end

    describe "Searching for forms" do
      it "should only return taxa with those forms" do
        citation = FactoryGirl.create :citation, forms: 'w.q.'
        protonym = FactoryGirl.create :protonym, authorship: citation
        atta = create_species protonym: protonym

        citation = FactoryGirl.create :citation, forms: 'q.'
        protonym = FactoryGirl.create :protonym, authorship: citation
        eciton = create_species protonym: protonym

        expect(Taxa::Search.advanced_search(rank: 'All', forms: 'w.').map(&:id)).to eq([atta.id])
      end
      it "should return nothing if nothing has those forms" do
        atta = create_species
        expect(Taxa::Search.advanced_search(rank: 'All', forms: 'w.').map(&:id)).to eq([])
      end
    end

  end
end
