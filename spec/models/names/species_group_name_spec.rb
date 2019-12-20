require 'rails_helper'

describe SpeciesGroupName do
  describe "#update_parent" do
    let!(:genus) { create :genus, name_string: 'Lasius' }
    let!(:species) { create :species, name_string: 'Lasius niger', genus: genus }

    context 'when the new name already exists' do
      let(:new_genus) { create :genus, name_string: 'Atta' }
      let(:existing_name) { create :species_name, name: 'Atta niger' }

      context 'when existing name belongs to a taxon' do
        before do
          create :species, name: existing_name
        end

        specify do
          new_genus = create :genus, name_string: 'Atta'

          expect do
            species.update_parent new_genus
            species.save!
          end.to raise_error(Taxon::TaxonExists)
        end
      end

      context 'when existing name belongs to a protonym' do
        before do
          create :protonym, name: existing_name
        end

        specify do
          expect do
            species.update_parent new_genus
            species.save!
          end.to change { species.reload.name_cache }.from('Lasius niger').to('Atta niger')
        end
      end
    end
  end
end
