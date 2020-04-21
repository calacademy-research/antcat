# frozen_string_literal: true

require 'rails_helper'

describe Autocomplete::ProtonymsQuery do
  describe "#call" do
    let!(:protonym) { create :protonym, name: create(:genus_name, name: 'Lasius') }
    let!(:other_protonym) { create :protonym, name: create(:genus_name, name: 'Atta') }

    specify do
      expect(described_class['Las']).to eq [protonym]
    end

    context 'when a protonym ID is given' do
      specify do
        expect(described_class[other_protonym.id.to_s]).to eq [other_protonym]
      end
    end
  end
end
