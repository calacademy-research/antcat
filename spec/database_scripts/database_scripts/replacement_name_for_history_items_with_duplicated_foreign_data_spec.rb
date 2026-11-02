# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::ReplacementNameForHistoryItemsWithDuplicatedForeignData do
  let(:script) { described_class.new }
  let(:senior) { create :species }

  def rendered
    DatabaseScripts::Render.new(script, {}).call
  end

  context "when the replaced homonym belongs to another protonym with the same homonym item" do
    let(:replacement) { create :species }
    let(:replaced) { create :species }

    before do
      create :history_item, :taxt, protonym: replacement.protonym,
        taxt: "Replacement name for {taxac #{replaced.id}} [Junior primary homonym of {taxac #{senior.id}}.]"
      create :history_item, :taxt, protonym: replaced.protonym, taxt: "[Junior primary homonym of {taxac #{senior.id}}.]"
    end

    it "offers to strip the identical data" do
      expect(script.results.size).to eq 1
      expect(rendered).to include 'Yes! Strip identical data!'
    end
  end

  context "when the tag points to a taxon of the item's own protonym" do
    let(:taxon) { create :species }

    before do
      create :history_item, :taxt, protonym: taxon.protonym,
        taxt: "Replacement name for {taxac #{taxon.id}} [Junior primary homonym of {taxac #{senior.id}}.]"
      create :history_item, :taxt, protonym: taxon.protonym, taxt: "[Junior primary homonym of {taxac #{senior.id}}.]"
    end

    it "offers no strip link (nothing foreign to strip)" do
      expect(script.results.size).to eq 1
      expect(rendered).not_to include 'Strip'
    end
  end
end
