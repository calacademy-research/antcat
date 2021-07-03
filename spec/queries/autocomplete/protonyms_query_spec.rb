# frozen_string_literal: true

require 'rails_helper'

describe Autocomplete::ProtonymsQuery, :search do
  describe "#call" do
    context 'when a protonym ID is given' do
      let!(:protonym) { create :protonym }

      specify do
        expect(described_class[protonym.id.to_s]).to eq [protonym]
      end
    end

    describe 'searching by protonym name' do
      let!(:protonym) { create :protonym, :species_group, name: create(:species_name, name: 'Lasius niger') }

      before do
        create :protonym # Non-match.
        Sunspot.commit
      end

      specify do
        expect(described_class['Las']).to eq [protonym]
        expect(described_class['Las nig']).to eq [protonym]
        expect(described_class['nig']).to eq [protonym]
      end
    end

    describe 'searching by protonym author names' do
      let!(:reference) { create :any_reference, author_string: 'Batiatus' }
      let!(:protonym) { create :protonym, authorship_reference: reference }

      before do
        create :protonym # Non-match.
        Sunspot.commit
      end

      specify do
        expect(described_class['bat']).to eq [protonym]
      end
    end

    describe 'searching by protonym author year' do
      let!(:reference) { create :any_reference, year: 2005 }
      let!(:protonym) { create :protonym, authorship_reference: reference }

      before do
        create :protonym # Non-match.
        Sunspot.commit
      end

      specify do
        expect(described_class['200']).to eq [protonym]
      end
    end

    describe 'searching in different fields at the same time' do
      let!(:reference) { create :any_reference, author_string: 'Batiatus', year: 2005 }
      let!(:protonym) do
        create :protonym, authorship_reference: reference, name: create(:genus_name, name: 'Formica')
      end

      before do
        create :protonym # Non-match.
        Sunspot.commit
      end

      specify do
        expect(described_class['bat form 2005']).to eq [protonym]
        expect(described_class['bat form 2006']).to eq []
      end
    end
  end
end
