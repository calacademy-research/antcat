# frozen_string_literal: true

require 'rails_helper'

describe History::Definition do
  subject(:definition) { described_class.new(type_attributes) }

  let(:type_attributes) { HistoryItem::TYPE_DEFINITIONS[type_definition_name] }

  describe '#groupable?' do
    context 'with groupable type' do
      let(:type_definition_name) { HistoryItem::FORM_DESCRIPTIONS }

      specify { expect(definition.groupable?).to eq true }
    end

    context 'without groupable type' do
      let(:type_definition_name) { HistoryItem::TYPE_SPECIMEN_DESIGNATION }

      specify { expect(definition.groupable?).to eq false }
    end
  end
end
