require 'rails_helper'

describe VirtualHistoryItems::SubspeciesList do
  describe '#relevant_for_taxon?' do
    context 'when species is not valid' do
      let!(:species) { create :species }

      before do
        create :subspecies, species: species
      end

      it 'returns false' do
        expect { species.status = Status::UNAVAILABLE }.
          to change { described_class.new(species).relevant_for_taxon? }.
          from(true).to(false)
      end
    end

    context 'when species is valid' do
      let!(:species) { create :species }
      let!(:subspecies) { create :subspecies, species: species }

      context 'when species has valid subspecies' do
        it 'returns true' do
          expect { subspecies.update!(status: Status::UNAVAILABLE) }.
            to change { described_class.new(species).relevant_for_taxon? }.
            from(true).to(false)
        end
      end
    end
  end

  describe '#render' do
    include TestLinksHelpers

    let!(:species) { create :species }
    let!(:subspecies) { create :subspecies, name_string: 'Lasius niger aa', species: species }
    let!(:unresolved_homonym_subspecies) do
      create :subspecies, name_string: 'Lasius niger zz', species: species, unresolved_homonym: true
    end

    context 'when the default formatter is used' do
      specify do
        expect(described_class.new(species).render).to eq <<~HTML.squish
          Current subspecies: nominal plus #{taxon_link(subspecies)},
          #{taxon_link(unresolved_homonym_subspecies)} (unresolved junior homonym).
        HTML
      end
    end

    context 'when `AntwebFormatter` is used' do
      specify do
        expect(described_class.new(species).render(formatter: AntwebFormatter)).to eq <<~HTML.squish
          Current subspecies: nominal plus #{antweb_taxon_link(subspecies)},
          #{antweb_taxon_link(unresolved_homonym_subspecies)} (unresolved junior homonym).
        HTML
      end
    end
  end
end
