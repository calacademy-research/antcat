# coding: UTF-8
require 'spec_helper'

class FormattersAdvancedSearchTextFormatterTestClass
  include Formatters::AdvancedSearchTextFormatter
end

describe Formatters::AdvancedSearchTextFormatter do
  before do
    @formatter = FormattersAdvancedSearchTextFormatterTestClass.new
  end

  describe "Formatting" do
    it "should format in text style, rather than HTML" do
      latreille = FactoryGirl.create :author_name, name: 'Latreille, P. A.'
      science = FactoryGirl.create :journal, name: 'Science'
      reference = FactoryGirl.create :article_reference, author_names: [latreille], citation_year: '1809', title: "*Atta*", journal: science, series_volume_issue: '(1)', pagination: '3'
      taxon = create_genus 'Atta', incertae_sedis_in: 'genus', nomen_nudum: true
      taxon.protonym.authorship.update_attributes reference: reference
      string = @formatter.format taxon
      expect(string).to eq('Atta incertae sedis in genus, nomen nudum'+"\n"+'Latreille, P. A. 1809. Atta. Science (1):3 DOI:<a class="document_link" href="http://dx.doi.org/10.10.1038/nphys1170" target="_blank">10.10.1038/nphys1170</a>.   '+reference.id.to_s+"\n\n")
    end
  end
end
