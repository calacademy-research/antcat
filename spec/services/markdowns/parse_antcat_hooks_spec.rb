# frozen_string_literal: true

# TODO: Consolidate AntCat markdown specs somewhere to avoid spec shotgun surgery. Maybe here.

require 'rails_helper'

describe Markdowns::ParseAntcatHooks do
  describe "#call" do
    it "does not remove <i> tags" do
      content = "<i>italics<i><i><script>xss</script></i>"
      expect(described_class[content]).to eq "<i>italics<i><i>xss</i></i></i>"
    end

    describe "tax tags (taxa)" do
      it "uses the HTML version of the taxon's name" do
        taxon = create :genus
        expect(described_class["{tax #{taxon.id}}"]).
          to eq %(<a href="/catalog/#{taxon.id}"><i>#{taxon.name_cache}</i></a>)
      end

      context "when the taxon can't be found" do
        it "adds a warning" do
          expect(described_class["{tax 999}"]).to include "CANNOT FIND TAXON WITH ID 999"
        end
      end
    end

    describe "tax tags with author citaion (taxa)" do
      it "uses the HTML version of the taxon's name" do
        taxon = create :genus
        expect(described_class["{taxac #{taxon.id}}"]).to eq <<~HTML.squish
          <a href="/catalog/#{taxon.id}"><i>#{taxon.name_cache}</i></a>
          <span class="discret-author-citation"><a href="/references/#{taxon.authorship_reference.id}">#{taxon.author_citation}</a></span>
        HTML
      end

      context "when the taxon can't be found" do
        it "adds a warning" do
          expect(described_class["{taxac 999}"]).to include "CANNOT FIND TAXON WITH ID 999"
        end
      end
    end

    describe "ref tags (references)" do
      context 'when reference has no expandable_reference_cache' do
        let(:reference) { create :any_reference, citation: 'Latreille, 1809 <script>' }

        it 'generates it' do
          expect(reference.expandable_reference_cache).to eq nil
          expect(described_class["{ref #{reference.id}}"]).to include 'Latreille'
        end
      end

      context "when the ref points to a reference that doesn't exist" do
        it "adds a warning" do
          expect(described_class["{ref 999}"]).to include "CANNOT FIND REFERENCE WITH ID 999"
        end
      end
    end
  end
end
