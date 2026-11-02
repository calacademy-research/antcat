# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::ReplacementNameForHistoryItemsWithDuplicatedSiblingItems do
  let(:script) { described_class.new }
  let(:senior) { create :species }
  let(:homonym_taxt) { "[Junior primary homonym of {taxac #{senior.id}}.]" }

  def rendered
    DatabaseScripts::Render.new(script, {}).call
  end

  context "when the replaced homonym belongs to another protonym" do
    let(:replacement) { create :species }
    let(:replaced) { create :species }

    before do
      create :history_item, :taxt, protonym: replacement.protonym, taxt: "Replacement name for {taxac #{replaced.id}}"
      create :history_item, :taxt, protonym: replacement.protonym, taxt: homonym_taxt
      create :history_item, :taxt, protonym: replaced.protonym, taxt: homonym_taxt
    end

    it "offers to delete the identical duplicate" do
      expect(rendered).to include 'Yes! Delete duplicate!'
    end
  end

  context "when the tag points to a taxon of the item's own protonym" do
    let(:taxon) { create :species }

    before do
      create :history_item, :taxt, protonym: taxon.protonym, taxt: "Replacement name for {taxac #{taxon.id}}"
      create :history_item, :taxt, protonym: taxon.protonym, taxt: homonym_taxt
    end

    it "offers no delete link (the item would be its own duplicate)" do
      expect(script.results.size).to eq 1
      expect(rendered).not_to include 'delete_history_item_quick_and_dirty_fix'
    end
  end
end
