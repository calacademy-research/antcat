require "spec_helper"

describe TaxtConverter do
  describe "#to_editor_format" do
    context "references" do
      it "uses the inline citation format followed by the id, with type number" do
        decorated = double 'keey'
        reference = double 'reference', id: 36
        expect(reference).to receive(:decorate).and_return decorated
        expect(decorated).to receive(:keey).and_return 'Fisher, 1922'
        expect(Reference).to receive(:find).and_return reference
        editable_keey = TaxtIdTranslator.send :id_for_editable, reference.id, 1

        expect(TaxtConverter["{ref #{reference.id}}"].to_editor_format).to eq "{Fisher, 1922 #{editable_keey}}"
      end

      it "handles missing references" do
        reference = create :missing_reference, citation: 'Fisher, 2011'
        editable_keey = TaxtIdTranslator.send :id_for_editable, reference.id, 1
        expect(TaxtConverter["{ref #{reference.id}}"].to_editor_format).to eq "{Fisher, 2011 #{editable_keey}}"
      end

      it "handles references we don't even know are missing" do
        expect(TaxtConverter["{ref 123}"].to_editor_format).to eq "{Rt}"
      end
    end

    context "taxa" do
      it "uses the taxon's name followed by its id" do
        genus = create_genus 'Atta'
        editable_keey = TaxtIdTranslator.send :id_for_editable, genus.id, 2
        expect(TaxtConverter["{tax #{genus.id}}"].to_editor_format).to eq "{Atta #{editable_keey}}"
      end
    end

    context "names" do
      it "uses the name followed by its id" do
        genus = create_genus 'Atta'
        editable_keey = TaxtIdTranslator.send :id_for_editable, genus.name.id, 3
        expect(TaxtConverter["{nam #{genus.name.id}}"].to_editor_format).to eq "{Atta #{editable_keey}}"
      end
    end
  end

  describe "#from_editor_format" do
    context "references" do
      it "uses the inline citation format followed by the id" do
        reference = create :article_reference
        editable_keey = TaxtIdTranslator.send :id_for_editable, reference.id, 1
        expect(TaxtConverter["{Fisher, 1922 #{editable_keey}}"].from_editor_format).to eq "{ref #{reference.id}}"
      end

      it "handles more than one reference" do
        reference = create :article_reference
        other_reference = create :article_reference
        editable_keey = TaxtIdTranslator.send :id_for_editable, reference.id, 1
        other_editable_keey = TaxtIdTranslator.send :id_for_editable, other_reference.id, 1

        taxt = "{Fisher, 1922 #{editable_keey}}, also {Bolton, 1970 #{other_editable_keey}}"
        results = TaxtConverter[taxt].from_editor_format
        expect(results).to eq "{ref #{reference.id}}, also {ref #{other_reference.id}}"
      end
    end

    context "taxa" do
      it "uses the taxon's name followed by its id" do
        genus = create_genus 'Atta'
        editable_keey = TaxtIdTranslator.send :id_for_editable, genus.id, 2
        expect(TaxtConverter["{Atta #{editable_keey}}"].from_editor_format).to eq "{tax #{genus.id}}"
      end
    end
  end
end
