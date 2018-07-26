require 'spec_helper'

class FormattersAdvancedSearchHtmlFormatterTestClass
  include Formatters::AdvancedSearchHtmlFormatter
  include ActionView::Helpers::TagHelper # For `#content_tag`.
  include ActionView::Context # For `#content_tag`.
end

describe Formatters::AdvancedSearchHtmlFormatter do
  subject(:formatter) { FormattersAdvancedSearchHtmlFormatterTestClass.new }

  describe "#format" do
    it "formats a taxon" do
      latreille = create :author_name, name: 'Latreille, P. A.'
      science = create :journal, name: 'Science'
      reference = create :article_reference,
        author_names: [latreille], citation_year: '1809', title: "*Atta*",
        journal: science, series_volume_issue: '(1)', pagination: '3'
      taxon = create_genus 'Atta', incertae_sedis_in: 'genus', nomen_nudum: true
      taxon.protonym.authorship.update reference: reference

      results = formatter.format_status_reference(taxon)
      expect(results).to eq "<i>incertae sedis</i> in genus, <i>nomen nudum</i>"

      results = formatter.format_type_localities(taxon)
      expect(results).to eq ""
    end
  end
end
