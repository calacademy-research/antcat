require 'rails_helper'

describe ProtonymDecorator do
  describe "#format_locality" do
    context 'when `locality` contains parentheses' do
      let(:protonym) { build_stubbed :protonym, locality: 'Indonesia (Timor)' }

      it 'does not capitalize words wrapped in parentheses' do
        expect(protonym.decorate.format_locality).to eq "INDONESIA (Timor)."
      end

      # TODO: Use `mb_chars`, https://api.rubyonrails.org/classes/String.html#method-i-mb_chars
      context 'when locality contains non-ASCII characters' do
        let(:protonym) { build_stubbed :protonym, locality: 'São Tomé & Príncipe (São Tomé I.)' }

        xit 'capitalizes properly' do
          expect(protonym.decorate.format_locality).to eq "SÃO TOMÉ & PRÍNCIPE (São Tomé I.)."
        end
      end
    end
  end
end
