require "spec_helper"

describe TaxonDecorator::HeadlineProtonym do
  describe "#protonym_name" do
    context "when a family name" do
      let(:protonym) { create :protonym }

      specify do
        expect(described_class.new(nil).send(:protonym_name, protonym)).
          to eq "<b><span>#{protonym.name.name_html}</span></b>"
      end
    end

    context "when a genus name" do
      let(:protonym) { create :protonym }

      specify do
        expect(described_class.new(nil).send(:protonym_name, protonym)).
          to eq "<b><span>#{protonym.name.name_html}</span></b>"
      end
    end

    context "when a fossil" do
      let(:protonym) { create :protonym, fossil: true }

      specify do
        expect(described_class.new(nil).send(:protonym_name, protonym)).
          to eq "<b><span><i>&dagger;</i>#{protonym.name.name_html}</span></b>"
      end
    end
  end
end
