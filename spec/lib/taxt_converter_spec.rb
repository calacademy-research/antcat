require "spec_helper"

describe TaxtConverter do
  describe "#to_editor_format" do
    context "references" do
      it "uses the inline citation format followed by the id, with type number" do
        decorated = double 'keey'
        reference = double 'reference', id: 36
        expect(reference).to receive(:keey).and_return 'Fisher, 1922'
        expect(Reference).to receive(:find_by).and_return reference
        jumbled_id = TaxtIdTranslator.send :jumble_id, reference.id, 1

        results = described_class["{ref #{reference.id}}"].to_editor_format
        expect(results).to eq "{Fisher, 1922 #{jumbled_id}}"
      end

      it "handles missing references" do
        reference = create :missing_reference, citation: 'Fisher, 2011'
        jumbled_id = TaxtIdTranslator.send :jumble_id, reference.id, 1

        results = described_class["{ref #{reference.id}}"].to_editor_format
        expect(results).to eq "{Fisher, 2011 #{jumbled_id}}"
      end

      it "handles references we don't even know are missing" do
        expect(described_class["{ref 123}"].to_editor_format).to eq "{Rt}"
      end
    end

    context "taxa" do
      it "uses the taxon's name followed by its id" do
        genus = create_genus 'Atta'
        jumbled_id = TaxtIdTranslator.send :jumble_id, genus.id, 2

        results = described_class["{tax #{genus.id}}"].to_editor_format
        expect(results).to eq "{Atta #{jumbled_id}}"
      end
    end

    context "names" do
      it "uses the name followed by its id" do
        genus = create_genus 'Atta'
        jumbled_id = TaxtIdTranslator.send :jumble_id, genus.name.id, 3

        results = described_class["{nam #{genus.name.id}}"].to_editor_format
        expect(results).to eq "{Atta #{jumbled_id}}"
      end
    end
  end

  describe "#from_editor_format" do
    context "references" do
      it "uses the inline citation format followed by the id" do
        reference = create :article_reference
        jumbled_id = TaxtIdTranslator.send :jumble_id, reference.id, 1

        results = described_class["{Fisher, 1922 #{jumbled_id}}"].from_editor_format
        expect(results).to eq "{ref #{reference.id}}"
      end

      it "handles more than one reference" do
        reference = create :article_reference
        other_reference = create :article_reference
        jumbled_id = TaxtIdTranslator.send :jumble_id, reference.id, 1
        other_jumbled_id = TaxtIdTranslator.send :jumble_id, other_reference.id, 1

        taxt = "{Fisher, 1922 #{jumbled_id}}, also {Bolton, 1970 #{other_jumbled_id}}"
        results = described_class[taxt].from_editor_format
        expect(results).to eq "{ref #{reference.id}}, also {ref #{other_reference.id}}"
      end
    end

    context "taxa" do
      it "uses the taxon's name followed by its id" do
        genus = create_genus 'Atta'
        jumbled_id = TaxtIdTranslator.send :jumble_id, genus.id, 2

        results = described_class["{Atta #{jumbled_id}}"].from_editor_format
        expect(results).to eq "{tax #{genus.id}}"
      end
    end
  end
end
