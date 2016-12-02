require "spec_helper"

describe DatabaseScripts::DatabaseScript do
  let(:script) { DatabaseTestScript.new }

  describe "#render" do
    context "the script has not defined #render" do
      it "can render a ActiveRecord::Relation" do
        create :article_reference
        allow(script).to receive(:results).and_return Reference.all

        expect(script.render).to match "<ul>\n<li>"
      end

      it "cannot render 'asdasda'" do
        allow(script).to receive(:results).and_return 'asdasda'
        expect(script.render).to match "Error: cannot implicitly render results."
      end
    end
  end

  describe "#as_taxon_table" do
    let!(:species) { create :species }

    it "doesn't require a description" do
      allow(script).to receive(:results).and_return [species]
      expect(script.as_taxon_table).to match "<table"
      expect(script.as_taxon_table).to match "<th>Taxon"
      expect(script.as_taxon_table).to match "<i>Atta species"
    end
  end

  describe "#as_reference_list" do
    let!(:refernece) { create :article_reference }

    it "doesn't require a description" do
      allow(script).to receive(:results).and_return [refernece]
      expect(script.as_reference_list).to match "<ul>\n<li>"
      expect(script.as_reference_list).to match "Ants are my life"
    end
  end
end
