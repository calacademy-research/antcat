# frozen_string_literal: true

require 'rails_helper'

describe History::Definitions, :relational_hi do
  describe 'TYPE_DEFINITIONS' do
    described_class::TYPE_DEFINITIONS.each do |type, definition|
      describe "type definition for #{type}" do
        it 'has all required attributes' do
          expect(definition[:type_label]).to be_present
          expect(definition[:ranks]).to be_present

          expect(definition[:group_order]).to be_present

          expect(definition[:templates]).to be_present
          expect(definition[:templates][:default]).to be_present

          expect(definition[:validates_presence_of]).to_not eq nil
        end
      end
    end
  end
end
