require "spec_helper"

describe TaxonDecorator::HeadlineProtonym do
  describe "#protonym_name" do
    context "when a family name" do
      let(:protonym) { create :protonym, name: create(:subfamily_name, name: 'Dolichoderinae') }

      specify do
        expect(described_class.new(nil).send(:protonym_name, protonym)).
          to eq '<b><span>Dolichoderinae</span></b>'
      end
    end

    context "when a genus name" do
      let(:protonym) { create :protonym, name: create(:genus_name, name: 'Atari') }

      specify do
        expect(described_class.new(nil).send(:protonym_name, protonym)).
          to eq '<b><span><i>Atari</i></span></b>'
      end
    end

    context "when a fossil" do
      let(:protonym) { create :protonym, name: create(:genus_name, name: 'Atari'), fossil: true }

      specify do
        expect(described_class.new(nil).send(:protonym_name, protonym)).
          to eq '<b><span><i>&dagger;</i><i>Atari</i></span></b>'
      end
    end
  end
end
