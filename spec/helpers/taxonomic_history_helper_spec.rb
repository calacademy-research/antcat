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
      replacement = Factory :genus, :name => 'Dlusskyidris', :taxonomic_history => '<p>Dlusskyidris history</p>'
      junior_homonym = Factory :genus, :name => 'Palaeomyrmex', :taxonomic_history => '<p>Palaeomyrmex history</p>', :status => 'homonym', :homonym_replaced_by => replacement
      helper.taxonomic_history(replacement).should == 
%{<p>Dlusskyidris history</p>} + 
%{<p>Homonym replaced by <i>DLUSSKYIDRIS</i></p>} +
%{<p><a href="#{browser_taxatry_path junior_homonym}">Palaeomyrmex</a></p>} + 
%{<p>Palaeomyrmex history</p>}
    end

  end

end
