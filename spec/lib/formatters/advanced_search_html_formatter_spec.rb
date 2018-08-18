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
      taxon = create_genus incertae_sedis_in: 'genus', nomen_nudum: true

      results = formatter.format_status_reference(taxon)
      expect(results).to eq "<i>incertae sedis</i> in genus, <i>nomen nudum</i>"

      results = formatter.format_type_localities(taxon)
      expect(results).to eq ""
    end
  end
end
