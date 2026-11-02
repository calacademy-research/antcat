# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::UnpairedJuniorSynonymOfHistoryItems, :relational_hi do
  let(:script) { described_class.new }
  let(:protonym_a) { create :protonym }
  let(:protonym_b) { create :protonym }
  let!(:junior_item) { create :history_item, :junior_synonym_of, protonym: protonym_a, object_protonym: protonym_b }

  context "when the object protonym's SeniorSynonymOf item points back" do
    before { create :history_item, :senior_synonym_of, protonym: protonym_b, object_protonym: protonym_a }

    specify { expect(script.results).to eq [] }
  end

  context "when the object protonym's SeniorSynonymOf item points to another protonym" do
    before { create :history_item, :senior_synonym_of, protonym: protonym_b, object_protonym: create(:protonym) }

    specify { expect(script.results).to eq [junior_item] }
  end
end
