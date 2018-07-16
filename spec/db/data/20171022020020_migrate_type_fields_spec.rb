require 'spec_helper'
require './db/data/20171022020020_migrate_type_fields'

describe MigrateTypeFields do
  describe '#up' do
    context 'when fields contains leading or trailing whitespace' do
      let!(:taxon) do
        create(:genus).tap do |taxon|
          taxon.update_columns verbatim_type_locality: '  one  ',
            type_specimen_code: '  two  ',
            type_specimen_repository: '  three  '
        end
      end

      it 'strips it before concatenating' do
        expect(taxon.verbatim_type_locality).to eq '  one  '
        expect(taxon.type_specimen_code).to eq '  two  '
        expect(taxon.type_specimen_repository).to eq '  three  '

        expect { described_class.up }.
          to change { taxon.reload.published_type_information }.
          to('one; two; three')
      end
    end

    describe 'content from `type_specimen_repository`' do
      context 'when there are more than one abbreviation' do
        context 'when abbreviations exist' do
          let!(:casc) { create :institution, :casc }
          let!(:amk) { create :institution, abbreviation: 'AMK', name: 'Ant Museum, Thailand' }
          let!(:taxon) { create :genus, type_specimen_repository: 'Lol (CASC) and (AMK)' }

          it 'does not modify the field' do
            expect { described_class.up }.
              to change { taxon.reload.published_type_information }.
              to(taxon.type_specimen_repository)
          end
        end
      end

      context 'when there is a single abbreviation in parentheses' do
        let!(:taxon) { create :genus, type_specimen_repository: 'Lol (CASC)' }

        context 'when abbreviation does not exists' do
          it 'does not modify the field' do
            expect { described_class.up }.
              to change { taxon.reload.published_type_information }.
              to(taxon.type_specimen_repository)
          end
        end

        context 'when abbreviation exists' do
          let!(:casc) { create :institution, :casc }

          it 'replaces it with the abbreviation only' do
            expect { described_class.up }.
              to change { taxon.reload.published_type_information }.to('CASC')
          end
        end
      end
    end
  end
end
