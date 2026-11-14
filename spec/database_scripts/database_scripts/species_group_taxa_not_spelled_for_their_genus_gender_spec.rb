# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::SpeciesGroupTaxaNotSpelledForTheirGenusGender do
  subject(:database_script) { described_class.new }

  let(:species) { create :species, name_string: 'Atta crassispinus' }

  before do
    species.genus.name.update!(gender: 'feminine')
    species.protonym.update!(
      gender_agreement_type: Protonym::ADJECTIVE,
      masculine_epithet: 'crassispinus', feminine_epithet: 'crassispina', neuter_epithet: 'crassispinum'
    )
  end

  describe "#results" do
    it "returns a species not spelled for the gender of its genus" do
      expect(database_script.results).to eq [species]
      expect(described_class.record_in_results?(species)).to eq true
    end

    context 'when the species is spelled for the gender of its genus' do
      before { species.genus.name.update!(gender: 'masculine') }

      specify { expect(database_script.results).to eq [] }
    end

    context 'when the genus has no gender' do
      before { species.genus.name.update!(gender: nil) }

      specify { expect(database_script.results).to eq [] }
    end

    context 'when the protonym records no spellings' do
      before do
        species.protonym.update!(masculine_epithet: nil, feminine_epithet: nil, neuter_epithet: nil)
      end

      specify { expect(database_script.results).to eq [] }
    end

    context 'when the spelling is kept on purpose (prevailing usage)' do
      before do
        species.protonym.update!(
          spelling_basis: 'incorrect_subsequent_spelling_in_prevailing_usage',
          interpretation_status: 'reasonably_inferred'
        )
      end

      specify { expect(database_script.results).to eq [] }
    end

    context 'when the reading is disputed' do
      before do
        species.protonym.update!(interpretation_status: 'disputed', notes_taxt: 'Spelling: an alternative reading.')
      end

      specify { expect(database_script.results).to eq [] }
    end

    context 'when the species is an unavailable misspelling' do
      let(:species) do
        create :species, :unavailable_misspelling, name_string: 'Atta crassispinus', current_taxon: create(:species)
      end

      specify { expect(database_script.results).to eq [] }
    end
  end
end
