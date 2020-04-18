# frozen_string_literal: true

require 'rails_helper'

describe Autocomplete::ProtonymsQuery do
  describe "#call" do
    let!(:protonym) { create :protonym, name: create(:genus_name, name: 'Lasius') }
    let!(:other_protonym) { create :protonym, name: create(:genus_name, name: 'Atta') }

    specify do
      expect(described_class['Las']).to eq(
        [
          {
            author_citation: protonym.authorship.reference.keey_without_letters_in_year,
            id: protonym.id,
            name_with_fossil: protonym.decorate.name_with_fossil
          }
        ]
      )
    end

    context 'when a protonym ID is given' do
      specify do
        expect(described_class[other_protonym.id.to_s]).to eq(
          [
            {
              author_citation: other_protonym.authorship.reference.keey_without_letters_in_year,
              id: other_protonym.id,
              name_with_fossil: other_protonym.decorate.name_with_fossil
            }
          ]
        )
      end
    end
  end
end
