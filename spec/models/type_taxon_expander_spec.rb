# frozen_string_literal: true

# TODO: Super sloppy tests. Revisit after moving `type_taxon` to the `Protonym`.

require 'rails_helper'

describe TypeTaxonExpander do
  include TestLinksHelpers

  describe '#expand' do
    subject(:expander) { described_class.new(taxon) }

    let(:taxon) { create :family, type_taxon: type_taxon }

    context 'when type taxon does not have a current valid taxon' do
      context 'when type taxon is valid' do
        let(:type_taxon) { create :family }

        specify { expect(expander.expansion(ignore_can_expand: false)).to eq '' }
      end

      context 'when type taxon not is valid' do
        let(:type_taxon) { create :family, :unavailable }

        specify do
          expect(expander.expansion(ignore_can_expand: false)).to eq " (unavailable)"
        end
      end
    end

    context 'when type taxon has a current valid taxon' do
      let(:current_valid_taxon_of_type_taxon) { create :family, :valid }
      let(:type_taxon) { create :family, :synonym, current_valid_taxon: current_valid_taxon_of_type_taxon }

      it "uses the status of the type taxon and links it's fully resolved current valid taxon" do
        expect(expander.expansion(ignore_can_expand: false)).
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
        expect(expander.expansion(ignore_can_expand: false)).
          to eq " (obsolete combination of #{taxon_link(second_current_valid_taxon_of_type_taxon)})"
      end
    end
  end
end
