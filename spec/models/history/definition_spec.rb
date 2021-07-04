# frozen_string_literal: true

require 'rails_helper'

describe History::Definition do
  describe '.from_type' do
    it 'instantiates a definition via a `type_name` (string)' do
      definition = described_class.from_type(History::Definitions::TYPE_SPECIMEN_DESIGNATION)
      expect(definition.type_label).to eq "Type specimen designation"
    end
  end

  describe '#groupable?' do
    subject(:definition) { described_class.new(type_attributes) }

    let(:type_attributes) { History::Definitions::TYPE_DEFINITIONS[type_definition_name] }

    context 'with groupable type' do
      let(:type_definition_name) { History::Definitions::FORM_DESCRIPTIONS }

      specify { expect(definition.groupable?).to eq true }
    end

    context 'without groupable type' do
      let(:type_definition_name) { History::Definitions::TYPE_SPECIMEN_DESIGNATION }

      specify { expect(definition.groupable?).to eq false }
    end
  end
end
