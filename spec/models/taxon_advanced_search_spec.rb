# coding: UTF-8
require 'spec_helper'

describe Taxon do

  describe "Advanced search" do
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
        Taxon.advanced_search(rank: 'Genus', year: 1977, valid_only: true).map(&:id).should =~ [atta.id, betta.id]
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
        Taxon.advanced_search(rank: 'Genus', year: 1977, valid_only: true).map(&:id).should =~ [atta.id, betta.id]
      end
      it "should return all regardless of validity if that flag is false" do
        reference1977 = reference_factory author_name: 'Bolton', citation_year: '1977'
        atta = create_genus
        atta.protonym.authorship.update_attributes! reference: reference1977
        atta.update_attributes! status: 'synonym'
        Taxon.advanced_search(rank: 'Genus', year: 1977, valid_only: false).map(&:id).should =~ [atta.id]
      end

      describe "Finding certain ranks" do
        before do
          taxa = []
          taxa << @subfamily = create_subfamily
          taxa << @tribe = create_tribe
          taxa << @genus = create_genus
          taxa << @subgenus = create_subgenus
          taxa << @species = create_species
          taxa << @subspecies = create_subspecies('Atta major minor')
          reference = reference_factory author_name: 'Bolton', citation_year: '1977'
          for taxon in taxa
            taxon.protonym.authorship.update_attributes! reference: reference
          end
        end

        it "should return just the requested rank, if asked" do
          Taxon.advanced_search(rank: 'Subfamily', year: 1977).map(&:id).should =~ [@subfamily.id]
          Taxon.advanced_search(rank: 'Tribe', year: 1977).map(&:id).should =~ [@tribe.id]
          Taxon.advanced_search(rank: 'Genus', year: 1977).map(&:id).should =~ [@genus.id]
          Taxon.advanced_search(rank: 'Subgenus', year: 1977).map(&:id).should =~ [@subgenus.id]
          Taxon.advanced_search(rank: 'Species', year: 1977).map(&:id).should =~ [@species.id]
          Taxon.advanced_search(rank: 'Subspecies', year: 1977).map(&:id).should =~ [@subspecies.id]
        end
      end
    end

  end
end
