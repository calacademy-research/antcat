# frozen_string_literal: true

require 'rails_helper'

describe TypeNameDecorator do
  include TestLinksHelpers

  let(:decorated) { type_name.decorate }

  describe '#compact_taxon_status' do
    let(:type_name) { create :type_name, taxon: type_taxon }

    context 'when type taxon does not have a current valid taxon' do
      context 'when type taxon is valid' do
        let(:type_taxon) { create :family }

        specify { expect(decorated.compact_taxon_status).to eq '' }
      end

      context 'when type taxon not is valid' do
        let(:type_taxon) { create :family, :unavailable }

        specify do
          expect(decorated.compact_taxon_status).to eq " (unavailable)"
        end
      end
    end

    context 'when type taxon has a current valid taxon' do
      let(:current_valid_taxon_of_type_taxon) { create :family, :valid }
      let(:type_taxon) { create :family, :synonym, current_valid_taxon: current_valid_taxon_of_type_taxon }

      it "uses the status of the type taxon and links it's fully resolved current valid taxon" do
        expect(decorated.compact_taxon_status).
          to eq " (junior synonym of #{taxon_link(current_valid_taxon_of_type_taxon)})"
      end
    end

    context 'when type taxon has a current valid taxon which itself has a current valid taxon' do
      let(:second_current_valid_taxon_of_type_taxon) { create :family, :valid }
      let(:current_valid_taxon_of_type_taxon) do
        create :family, :obsolete_combination, current_valid_taxon: second_current_valid_taxon_of_type_taxon
      end
      let(:type_taxon) { create :family, :synonym, current_valid_taxon: current_valid_taxon_of_type_taxon }

      it "uses the status of taxon before the fully resolved current valid taxon and links the fully resolved" do
        expect(decorated.compact_taxon_status).
          to eq " (obsolete combination of #{taxon_link(second_current_valid_taxon_of_type_taxon)})"
      end
    end
  end
end
