# frozen_string_literal: true

require 'rails_helper'

describe ApplicationHelper do
  describe "#or_dash" do
    specify do
      expect(helper.or_dash('')).to eq "–"
      expect(helper.or_dash(nil)).to eq "–"
      expect(helper.or_dash(0)).to eq "–"
      expect(helper.or_dash(Taxon)).to eq Taxon
    end
  end

  describe "#flash_message_class" do
    specify { expect(helper.flash_message_class("notice")).to eq "callout-blue" }
    specify { expect(helper.flash_message_class("alert")).to eq "callout-danger" }
    specify { expect(helper.flash_message_class("error")).to eq "callout-danger" }
  end

  describe "#external_link_to and #pdf_link_to" do
    it "links http(s) and protocol-relative URLs" do
      expect(helper.external_link_to('PDF', 'https://example.com/a.pdf')).
        to eq '<a class="external-link" href="https://example.com/a.pdf">PDF</a>'
      expect(helper.external_link_to('Scholar', '//scholar.google.com/scholar?q=x')).
        to eq '<a class="external-link" href="//scholar.google.com/scholar?q=x">Scholar</a>'
      expect(helper.pdf_link_to('PDF', 'http://example.com/a.pdf')).
        to eq '<a class="pdf-link" rel="nofollow" href="http://example.com/a.pdf">PDF</a>'
    end

    it "shows other URLs as plain text" do
      ['javascript:alert(1)', ' JavaScript:alert(1)', 'data:text/html,x', 'example.com', '', nil].each do |url|
        expect(helper.external_link_to('PDF', url)).to eq '<span>PDF</span>'
        expect(helper.pdf_link_to('PDF', url)).to eq '<span>PDF</span>'
      end
    end
  end
end
