require 'spec_helper'

describe ProtonymDecorator do
  describe "#format_locality" do
    context 'when `locality` contains parentheses' do
      let(:protonym) { build_stubbed :protonym, locality: 'Indonesia (Timor)' }

      it 'does not capitalize words wrapped in parentheses' do
        expect(protonym.decorate.format_locality).to eq "INDONESIA (Timor)."
      end
    end
  end
end
