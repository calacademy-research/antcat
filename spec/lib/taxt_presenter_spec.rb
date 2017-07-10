require "spec_helper"

describe TaxtPresenter do
  describe "#to_text" do
    it "renders text without links or HTML (except <i> tags)" do
      taxt = "{tax #{create(:family).id}}"
      expect(TaxtPresenter[taxt].to_text).to eq "Formicidae."
    end

    context "names that should be italicized" do
      let(:genus) { create_genus "Atta" }

      it "includes HTML <i> tags" do
        taxt = "{tax #{genus.id}}"
        expect(TaxtPresenter[taxt].to_text).to eq "<i>Atta</i>."
      end
    end
  end

  describe "#to_html" do
    describe "escaping input" do
      xit "escapes its input" do
        parsed = TaxtPresenter['<script>'].to_html
        expect(parsed).to eq '&lt;script&gt;'
        expect(parsed).to be_html_safe
      end

      it "doesn't escape already escaped input" do
        reference = create :missing_reference, citation: 'Latreille, 1809 <script>'
        expected = 'Latreille, 1809 &lt;script&gt;'
        expect(reference.decorate.inline_citation).to eq expected
        expect(TaxtPresenter["{ref #{reference.id}}"].to_html).to eq expected
      end
    end

    it "handles nil" do
      expect(TaxtPresenter[nil].to_html).to eq ''
    end

    describe "ref tags (references)" do
      context "when the ref tag is malformed" do
        it "doesn't freak" do
          expect(TaxtPresenter["{ref sdf}"].to_html).to eq '{ref sdf}'
        end
      end

      context "when the ref points to a reference that doesn't exist" do
        let(:results) { TaxtPresenter["{ref 999}"].to_html }

        it "adds a warning" do
          expect(results).to match "CANNOT FIND REFERENCE WITH ID 999"
        end

        it "includes a 'Search history?' link" do
          expect(results).to match "Search history?"
        end
      end

      it "handles missing references" do
        reference = create :missing_reference, citation: 'Latreille, 1809'
        expect(TaxtPresenter["{ref #{reference.id}}"].to_html).to eq 'Latreille, 1809'
      end
    end

    describe "nam tags (names)" do
      it "returns the HTML version of the name" do
        name = create :subspecies_name, name_html: '<i>Atta major minor</i>'
        expect(TaxtPresenter["{nam #{name.id}}"].to_html).to eq '<i>Atta major minor</i>'
      end

      context "when the name can't be found" do
        let(:results) { TaxtPresenter["{nam 999}"].to_html }

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
        genus = create_genus name: create(:genus_name, name_html: '<i>Atta</i>')
        expect(TaxtPresenter["{tax #{genus.id}}"].to_html)
          .to eq %{<a href="/catalog/#{genus.id}"><i>Atta</i></a>}
      end

      context "when the taxon is a fossil" do
        it "includes the fossil symbol" do
          genus = create_genus name: create(:genus_name, name_html: '<i>Atta</i>'), fossil: true
          expect(TaxtPresenter["{tax #{genus.id}}"].to_html)
            .to eq %{<a href="/catalog/#{genus.id}"><i>&dagger;</i><i>Atta</i></a>}
        end
      end

      context "when the taxon can't be found" do
        let(:results) { TaxtPresenter["{tax 999}"].to_html }

        it "adds a warning" do
          expect(results).to match "CANNOT FIND TAXON WITH ID 999"
        end

        it "includes a 'Search history?' link" do
          expect(results).to match "Search history?"
        end
      end
    end
  end

  describe "#to_antweb" do
    let(:taxt) { "{tax #{create(:family).id}}" }

    it "uses a different link formatter" do
      expect(TaxtPresenter[taxt].to_antweb).to match "antcat.org"
    end

    describe "the `$use_ant_web_formatter` quirk" do
      before { $use_ant_web_formatter = true }
      after { $use_ant_web_formatter = nil }

      it "***confirm test setup***" do
        $use_ant_web_formatter = nil
        expect(TaxtPresenter[taxt].to_html).to_not match "antcat.org"
      end

      it "makes all formatters behave like #to_antweb" do
        expect(TaxtPresenter[taxt].to_html).to match "antcat.org"
        expect(TaxtPresenter[taxt].to_text).to match "antcat.org"
        expect(TaxtPresenter[taxt].to_antweb).to match "antcat.org"
      end

      describe 'broken taxt tags' do
        describe "ref tags (references)" do
          let(:results) { TaxtPresenter["{ref 999}"].to_html }

          context "when the ref points to a reference that doesn't exist" do
            it "adds a warning" do
              expect(results).to match "CANNOT FIND REFERENCE WITH ID 999"
            end

            it "doesn't include a 'Search history?' link" do
              expect(results).to_not match "Search history?"
            end
          end
        end

        describe "nam tags (names)" do
          context "when the name can't be found" do
            let(:results) { TaxtPresenter["{nam 999}"].to_html }

            it "adds a warning" do
              expect(results).to match "CANNOT FIND NAME WITH ID 999"
            end

            it "doesn't include a 'Search history?' link" do
              expect(results).to_not match "Search history?"
            end
          end
        end

        describe "tax tags (taxa)" do
          let(:results) { TaxtPresenter["{tax 999}"].to_html }

          context "when the taxon can't be found" do
            it "adds a warning" do
              expect(results).to match "CANNOT FIND TAXON WITH ID 999"
            end

            it "doesn't include a 'Search history?' link" do
              expect(results).to_not match "Search history?"
            end
          end
        end
      end
    end
  end
end
