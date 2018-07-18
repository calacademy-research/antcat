require 'spec_helper'

describe BreadcrumbsHelper do
  describe "#taxon_breadcrumb_link" do
    context "when Formicidae" do
      let(:taxon) { create :family }

      it "handles Formicidae" do
        expect(helper.taxon_breadcrumb_link(taxon)).
          to eq %(<a href="/catalog/#{taxon.id}">#{taxon.name_cache}</a>)
      end
    end

    context "when 'non-italic' ranks" do
      let(:ranks) { [:subfamily, :tribe] }

      specify do
        ranks.each do |rank|
          taxon = send "create_#{rank}"
          expect(helper.taxon_breadcrumb_link(taxon)).
            to eq %(<a href="/catalog/#{taxon.id}">#{taxon.name_cache}</a>)
        end
      end
    end

    # TODO? it "handles subtribes"; factory broken

    context "when 'italic' ranks" do
      let(:ranks) { [:genus, :species, :subspecies] }

      specify do
        ranks.each do |rank|
          taxon = send "create_#{rank}"
          expect(helper.taxon_breadcrumb_link(taxon)).
            to eq %(<a href="/catalog/#{taxon.id}"><i>#{taxon.name_cache}</i></a>)
        end
      end
    end

    # TODO? it "handles subgenera"; factory broken

    context "when fossil taxa" do
      let(:taxon) { create_genus fossil: true }

      specify do
        expect(helper.taxon_breadcrumb_link(taxon)).
          to eq %(<a href="/catalog/#{taxon.id}">&dagger;<i>#{taxon.name_cache}</i></a>)
      end
    end
  end
end
