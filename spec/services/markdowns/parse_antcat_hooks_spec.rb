# TODO consolidate AntCat markdown specs somewhere to avoid spec shotgun surgery. Maybe here.

require "spec_helper"

describe Markdowns::ParseAntcatHooks do
  describe "#call" do
    it "does not remove <i> tags" do
      content = "<i>italics<i><i><script>xss</script></i>"
      expect(described_class[content]).to eq "<i>italics<i><i>xss</i></i></i>"
    end

    describe "ref tags (references)" do
      context 'when reference has no expandable_reference_cache' do
        let(:reference) { create :unknown_reference, citation: 'Latreille, 1809 <script>' }

        it 'generates it' do
          expect(reference.expandable_reference_cache).to eq nil
          expect(described_class["{ref #{reference.id}}"]).to include 'Latreille'
        end
      end

      context "when the ref points to a reference that doesn't exist" do
        let(:results) { described_class["{ref 999}"] }

        it "adds a warning" do
          expect(results).to match "CANNOT FIND REFERENCE WITH ID 999"
        end

        it "includes a 'Search history?' link" do
          expect(results).to match "Search history?"
        end
      end
    end

    describe "nam tags (names)" do
      it "returns the HTML version of the name" do
        name = create :subspecies_name
        expect(described_class["{nam #{name.id}}"]).to eq name.to_html
      end

      context "when the name can't be found" do
        let(:results) { described_class["{nam 999}"] }

        it "adds a warning" do
          expect(results).to match "CANNOT FIND NAME WITH ID 999"
        end

        it "includes a 'Search history?' link" do
          expect(results).to match "Search history?"
        end
      end
    end

    describe "tax tags (taxa)" do
      it "uses the HTML version of the taxon's name" do
        taxon = create :genus
        expect(described_class["{tax #{taxon.id}}"]).
          to eq %(<a href="/catalog/#{taxon.id}"><i>#{taxon.name_cache}</i></a>)
      end

      context "when taxon is fossil" do
        let!(:taxon) { create :genus, :fossil }

        it "includes the fossil symbol" do
          expect(described_class["{tax #{taxon.id}}"]).
            to eq %(<a href="/catalog/#{taxon.id}"><i>&dagger;</i><i>#{taxon.name_cache}</i></a>)
        end
      end

      context "when the taxon can't be found" do
        let(:results) { described_class["{tax 999}"] }

        it "adds a warning" do
          expect(results).to match "CANNOT FIND TAXON WITH ID 999"
        end

        it "includes a 'Search history?' link" do
          expect(results).to match "Search history?"
        end
      end
    end
  end

  context "when record does not exists" do
    it "renders an error message" do
      expect(described_class["{tax 9999}"]).to eq <<~HTML.squish
        <span class="bold-warning">
          CANNOT FIND TAXON WITH ID 9999
          <a class="btn-normal btn-tiny" href="/panel/versions?item_id=9999">Search history?</a>
        </span>
      HTML
    end
  end
end
