require 'spec_helper'

class FormattersAdvancedSearchHtmlFormatterTestClass
  include Formatters::AdvancedSearchHtmlFormatter
end

describe Formatters::AdvancedSearchHtmlFormatter do
  let(:formatter) { FormattersAdvancedSearchHtmlFormatterTestClass.new }

  it "should format a taxon" do
    latreille = create :author_name, name: 'Latreille, P. A.'
    science = create :journal, name: 'Science'
    reference = create :article_reference,
      author_names: [latreille], citation_year: '1809', title: "*Atta*",
      journal: science, series_volume_issue: '(1)', pagination: '3'
    taxon = create_genus 'Atta', incertae_sedis_in: 'genus', nomen_nudum: true
    taxon.protonym.authorship.update_attributes reference: reference

    actual = formatter.format taxon
    expect(actual).to eq(
      "<a href=\"/catalog/#{taxon.id}\"><i>Atta</i></a> <i>incertae sedis</i> in genus, <i>nomen nudum</i>\n<span class=\"reference_key_and_expansion\"><a class=\"reference_key\" title=\"Latreille, P. A. 1809. Atta. Science (1):3.\" href=\"#\">Latreille, 1809</a><span class=\"reference_key_expansion\"><span class=\"reference_key_expansion_text\" title=\"Latreille, 1809\">Latreille, P. A. 1809. <i>Atta</i>. Science (1):3.</span> <a class=\"document_link\" target=\"_blank\" href=\"http://dx.doi.org/10.10.1038/nphys1170\">10.10.1038/nphys1170</a> <a class=\"goto_reference_link\" target=\"_blank\" href=\"/references/#{reference.id}\">#{reference.id}</a></span></span>\n\n"
    )
  end
end
