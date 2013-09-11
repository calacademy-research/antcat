# coding: UTF-8
require 'spec_helper'

class FormattersAdvancedSearchHtmlFormatterTestClass
  include Formatters::AdvancedSearchHtmlFormatter
end

describe Formatters::AdvancedSearchHtmlFormatter do
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
      string.should == 
"<a href=\"/catalog/#{taxon.id}\"><i>Atta</i></a> " +
"<i>incertae sedis</i> in genus, <i>nomen nudum</i>\n" +
"Latreille, P. A. 1809. " +
"<i>Atta</i>. Science (1):3." +
"<a class=\"goto_reference_link\" href=\"/references?q=#{reference.id}\" target=\"_blank\">" +
"<img alt=\"External_link\" src=\"/assets/external_link.png\" /></a>" +
"<span class=\"reference_id\">#{reference.id}</span>\n\n"
  end

end
