# coding: UTF-8
require 'spec_helper'

class FormattersAdvancedSearchHtmlFormatterTestClass
  include Formatters::AdvancedSearchHtmlFormatter
end

describe Formatters::AdvancedSearchFormatter do
  before do
    @formatter = FormattersAdvancedSearchHtmlFormatterTestClass.new
  end

  it "should format a taxon" do
      latreille = FactoryGirl.create :author_name, name: 'Latreille, P. A.'
      science = FactoryGirl.create :journal, name: 'Science'
      reference = FactoryGirl.create :article_reference, author_names: [latreille], citation_year: '1809', title: "*Atta*", journal: science, series_volume_issue: '(1)', pagination: '3'
      taxon = create_genus 'Atta', incertae_sedis_in: 'genus', nomen_nudum: true
      taxon.protonym.authorship.update_attributes reference: reference
      string = @formatter.format taxon
      string.should == "<i>Atta</i> <i>incertae sedis</i> in genus, nomen nudum\nLatreille, P. A. 1809. Atta. Science (1):3.<span class=\"reference_id\">#{reference.id}</span>\n\n"
  end

end
