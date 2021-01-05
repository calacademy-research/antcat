# frozen_string_literal: true

require 'rails_helper'

describe Autocomplete::ProtonymSerializer do
  describe "#as_json" do
    let!(:protonym) do
      create :protonym, :species_group_name, :fossil, name: create(:species_name, name: 'Lasius var. niger')
    end

    specify do
      expect(described_class.new(protonym).as_json).to eq(
        {
          id: protonym.id,
          plaintext_name: 'Lasius var. niger',
          name_with_fossil: "<i>†</i><i>Lasius var. niger</i>",
          author_citation: protonym.author_citation,
          css_classes: 'protonym',
          url: "/protonyms/#{protonym.id}"
        }
      )
    end
  end
end
