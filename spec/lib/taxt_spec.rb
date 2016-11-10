# TODO split file and cleanup.

require 'spec_helper'

describe Taxt do
  describe "Editable taxt" do
    describe ".to_editable" do
      context "References" do
        it "uses the inline citation format followed by the id, with type number" do
          decorated = double 'keey'
          reference = double 'reference', id: 36
          expect(reference).to receive(:decorate).and_return decorated
          expect(decorated).to receive(:keey).and_return 'Fisher, 1922'
          expect(Reference).to receive(:find).and_return reference
          editable_keey = TaxtConverter.send :id_for_editable, reference.id, 1

          expect(TaxtConverter["{ref #{reference.id}}"].to_editor_format).to eq "{Fisher, 1922 #{editable_keey}}"
        end

        it "handles missing references" do
          reference = create :missing_reference, citation: 'Fisher, 2011'
          editable_keey = TaxtConverter.send :id_for_editable, reference.id, 1
          expect(TaxtConverter["{ref #{reference.id}}"].to_editor_format).to eq "{Fisher, 2011 #{editable_keey}}"
        end

        it "handles references we don't even know are missing" do
          expect(TaxtConverter["{ref 123}"].to_editor_format).to eq "{Rt}"
        end
      end

      context "Taxa" do
        it "uses the taxon's name followed by its id" do
          genus = create_genus 'Atta'
          editable_keey = TaxtConverter.send :id_for_editable, genus.id, 2
          expect(TaxtConverter["{tax #{genus.id}}"].to_editor_format).to eq "{Atta #{editable_keey}}"
        end
      end

      context "Names" do
        it "uses the name followed by its id" do
          genus = create_genus 'Atta'
          editable_keey = TaxtConverter.send :id_for_editable, genus.name.id, 3
          expect(TaxtConverter["{nam #{genus.name.id}}"].to_editor_format).to eq "{Atta #{editable_keey}}"
        end
      end
    end

    describe ".from_editable" do
      describe "{ref}" do
        it "uses the inline citation format followed by the id" do
          reference = create :article_reference
          editable_keey = TaxtConverter.send :id_for_editable, reference.id, 1
          expect(TaxtConverter["{Fisher, 1922 #{editable_keey}}"].from_editor_format).to eq "{ref #{reference.id}}"
        end

        it "handles more than one reference" do
          reference = create :article_reference
          other_reference = create :article_reference
          editable_keey = TaxtConverter.send :id_for_editable, reference.id, 1
          other_editable_keey = TaxtConverter.send :id_for_editable, other_reference.id, 1

          taxt = "{Fisher, 1922 #{editable_keey}}, also {Bolton, 1970 #{other_editable_keey}}"
          results = TaxtConverter[taxt].from_editor_format
          expect(results).to eq "{ref #{reference.id}}, also {ref #{other_reference.id}}"
        end
      end

      context "Taxa" do
        it "uses the taxon's name followed by its id" do
          genus = create_genus 'Atta'
          editable_keey = TaxtConverter.send :id_for_editable, genus.id, 2
          expect(TaxtConverter["{Atta #{editable_keey}}"].from_editor_format).to eq "{tax #{genus.id}}"
        end
      end
    end
  end

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

  describe ".to_string" do
    it "ignores strings without fields" do
      string = TaxtPresenter['foo'].to_html
      expect(string).to eq 'foo'
      expect(string).to be_html_safe
    end

    #it "escapes its input" do
      #string = TaxtPresenter['<script>'].to_html
      #string.should == '&lt;script&gt;'
      #string.should be_html_safe
    #end

    it "handles nil" do
      expect(TaxtPresenter[nil].to_html).to eq ''
    end

    describe "Reference" do
      describe "Linked" do
        it "doesn't freak if the ref is malformed" do
          expect(TaxtPresenter["{ref sdf}"].to_html).to eq '{ref sdf}'
        end

        it "doesn't freak if the ref points to a reference that doesn't exist" do
          expect(TaxtPresenter["{ref 12345}"].to_html).to eq '{ref 12345}'
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
    end

    describe "Name" do
      describe "Links" do
        it "returns the HTML version of the name" do
          name = create :subspecies_name, name_html: '<i>Atta major minor</i>'
          expect(TaxtPresenter["{nam #{name.id}}"].to_html).to eq '<i>Atta major minor</i>'
        end

        it "doesn't freak if the name can't be found" do
          expect(TaxtPresenter["{nam 12345}"].to_html).to eq '{nam 12345}'
        end
      end
    end

    describe "AntWeb formatter quirk" do
      before do
        $use_ant_web_formatter = true
      end
      after do
        $use_ant_web_formatter = nil
      end

      it "can use a different link formatter" do
        genus = create_genus name: create(:genus_name, name_html: '<i>Atta</i>')
        expect_any_instance_of(TaxtPresenter).to receive(:link_to_antcat_from_antweb).and_call_original
        TaxtPresenter["{tax #{genus.id}}"].to_html
      end
    end

    describe "Taxon" do
      describe "Linked" do
        it "uses the HTML version of the taxon's name" do
          genus = create_genus name: create(:genus_name, name_html: '<i>Atta</i>')
          expect(TaxtPresenter["{tax #{genus.id}}"].to_html)
            .to eq %{<a href="/catalog/#{genus.id}"><i>Atta</i></a>}
        end

        it "includes the fossil symbol if applicable" do
          genus = create_genus name: create(:genus_name, name_html: '<i>Atta</i>'), fossil: true
          expect(TaxtPresenter["{tax #{genus.id}}"].to_html)
            .to eq %{<a href="/catalog/#{genus.id}"><i>&dagger;</i><i>Atta</i></a>}
        end

        it "doesn't freak if the taxon can't be found" do
          expect(TaxtPresenter["{tax 12345}"].to_html).to eq '{tax 12345}'
        end

        it "uses the HTML version of the taxon's name" do
          genus = create_genus name: create(:genus_name, name_html: '<i>Atta</i>')
          expect(TaxtPresenter["{tax #{genus.id}}"].to_html)
            .to eq %{<a href="/catalog/#{genus.id}"><i>Atta</i></a>}
        end
      end
    end
  end
end
