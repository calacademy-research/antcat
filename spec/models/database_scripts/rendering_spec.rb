# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::Rendering do
  let(:script) { DatabaseTestScript.new }

  describe "#render" do
    context "when the script has not defined `#render`" do
      it "can render an ActiveRecord::Relation" do
        create :any_reference
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
    let!(:taxon) { create :genus, name_string: "Lasius" }

    it "doesn't require a description" do
      allow(script).to receive(:results).and_return [taxon]
      expect(script.as_taxon_table).to match "<table"
      expect(script.as_taxon_table).to match "<th>Taxon"
      expect(script.as_taxon_table).to match "<i>Lasius</i>"
    end
  end

  describe "#as_reference_list" do
    let!(:refernece) { create :any_reference, title: "Pizza Ants" }

    it "doesn't require a description" do
      allow(script).to receive(:results).and_return [refernece]
      expect(script.as_reference_list).to match "<ul>\n<li>"
      expect(script.as_reference_list).to match "Pizza Ants"
    end
  end
end
