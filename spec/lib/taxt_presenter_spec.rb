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
    #it "escapes its input" do
      #string = TaxtPresenter['<script>'].to_html
      #string.should == '&lt;script&gt;'
      #string.should be_html_safe
    #end

    it "handles nil" do
      expect(TaxtPresenter[nil].to_html).to eq ''
    end

    context "references" do
      context "when the ref is malformed" do
        it "doesn't freak" do
          expect(TaxtPresenter["{ref sdf}"].to_html).to eq '{ref sdf}'
        end
      end

      context "when the ref points to a reference that doesn't exist" do
        it "doesn't freak" do
          expect(TaxtPresenter["{ref 12345}"].to_html).to eq '{ref 12345}'
        end
      end

      it "handles a MissingReference" do
        reference = create :missing_reference, citation: 'Latreille, 1809'
        expect(TaxtPresenter["{ref #{reference.id}}"].to_html).to eq 'Latreille, 1809'
      end

      #it "escapes input" do
        #reference = create :missing_reference, citation: 'Latreille, 1809 <script>'
        #TaxtPresenter["{ref #{reference.id}}"].to_html.should == 'Latreille, 1809 &lt;script&gt;'
      #end
    end

    context "names" do
      it "returns the HTML version of the name" do
        name = create :subspecies_name, name_html: '<i>Atta major minor</i>'
        expect(TaxtPresenter["{nam #{name.id}}"].to_html).to eq '<i>Atta major minor</i>'
      end

      context "when the name can't be found" do
        it "doesn't freak" do
          expect(TaxtPresenter["{nam 12345}"].to_html).to eq '{nam 12345}'
        end
      end
    end

    describe "taxa" do
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
        it "doesn't freak" do
          expect(TaxtPresenter["{tax 12345}"].to_html).to eq '{tax 12345}'
        end
      end
    end
  end

  describe "#to_antweb_export" do
    before { $use_ant_web_formatter = true }
    after { $use_ant_web_formatter = nil }

    it "uses a different link formatter" do
      taxt = "{tax #{create(:family).id}}"
      expect_any_instance_of(TaxtPresenter).to receive(:link_to_antcat_from_antweb).and_call_original
      TaxtPresenter[taxt].to_html
    end
  end
end
