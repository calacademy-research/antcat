# frozen_string_literal: true

require 'rails_helper'

describe Autocomplete::ProtonymsQuery do
  describe "#call" do
    let!(:protonym) { create :protonym, :species_group_name, name: create(:species_name, name: 'Lasius niger') }
    let!(:other_protonym) { create :protonym, name: create(:genus_name, name: 'Atta') }

    specify do
      expect(described_class['Las']).to eq [protonym]
      expect(described_class['Las nig']).to eq [protonym]
      expect(described_class['nig']).to eq [protonym]
    end

    context 'when a protonym ID is given' do
      specify do
        expect(described_class[other_protonym.id.to_s]).to eq [other_protonym]
      end
    end
  end
end
