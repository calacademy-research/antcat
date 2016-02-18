require 'spec_helper'

describe BreadcrumbsHelper do
  describe "#taxon_breadcrumb_link" do
    it "handles Formicidae" do
      taxon = create_family
      expected = %Q[<a href="/catalog/#{taxon.id}">#{taxon.name_cache}</a>]
      expect(helper.taxon_breadcrumb_link(taxon)).to eq expected
    end

    it "handles 'non-italic' ranks" do
      ranks = [:subfamily, :tribe]
      ranks.each do |rank|
        taxon = send "create_#{rank}"
        expected = %Q[<a href="/catalog/#{taxon.id}">#{taxon.name_cache}</a>]
        expect(helper.taxon_breadcrumb_link(taxon)).to eq expected
      end
    end

    # TODO? it "handles subtribes"; factory broken

    it "handles 'italic' ranks" do
      ranks = [:genus, :species, :subspecies]
      ranks.each do |rank|
        taxon = send "create_#{rank}"
        expected = %Q[<a href="/catalog/#{taxon.id}"><i>#{taxon.name_cache}</i></a>]
        expect(helper.taxon_breadcrumb_link(taxon)).to eq expected
      end
    end

    # TODO? it "handles subgenera"; factory broken

    it "handles fossil taxa" do
      taxon = create_genus fossil: true
      expected = %Q[<a href="/catalog/#{taxon.id}">&dagger;<i>#{taxon.name_cache}</i></a>]
      expect(helper.taxon_breadcrumb_link(taxon)).to eq expected
    end
  end
end
