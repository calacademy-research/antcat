require 'spec_helper'

describe TaxonomicHistoryHelper do

  describe 'Simple' do

    it "should return the field" do
      genus = Factory :genus, :taxonomic_history => 'foo'
      helper.taxonomic_history(genus).should == 'foo'
    end

  end

  describe 'With homonyms' do

    it "should return the field + the list of homonyms" do
      replacement = Factory :genus, :name => 'Dlusskyidris', :taxonomic_history => '<p>Dlusskyidris history</p>', :fossil => true
      junior_homonym = Factory :genus, :name => 'Palaeomyrmex', :taxonomic_history => '<p>Palaeomyrmex history</p>', :status => 'homonym', :homonym_replaced_by => replacement
      helper.taxonomic_history(replacement).should == 
%{<p>Dlusskyidris history</p>} + 
%{<p class="taxon_subsection_header">Homonym replaced by <span class="genus taxon valid">&dagger;DLUSSKYIDRIS</span></p>} +
%{<p>Palaeomyrmex history</p>}
    end

  end

end
