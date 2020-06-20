# frozen_string_literal: true

require 'rails_helper'

describe ProtonymDecorator do
  describe "#format_locality" do
    context 'when `locality` contains parentheses' do
      context 'when locality contains words in parentheses' do
        let(:protonym) { build_stubbed :protonym, locality: 'Indonesia (Timor)' }

        it 'does not capitalize words wrapped in parentheses' do
          expect(protonym.decorate.format_locality).to eq "INDONESIA (Timor)."
        end
      end

      context 'when locality contains non-ASCII characters' do
        let(:protonym) { build_stubbed :protonym, locality: 'São Tomé & Príncipe (São Tomé I.)' }

        it 'capitalizes properly' do
          expect(protonym.decorate.format_locality).to eq "SÃO TOMÉ & PRÍNCIPE (São Tomé I.)."
        end
      end

      context 'when `uncertain_locality`' do
        let(:protonym) { build_stubbed :protonym, :uncertain_locality, locality: 'Indonesia (Timor)' }

        it 'includes it in brackets' do
          expect(protonym.decorate.format_locality).to eq "INDONESIA (Timor) [uncertain]."
        end
      end
    end
  end

  describe "#format_pages_and_forms" do
    context 'when protonym has `forms`' do
      let(:citation) { build_stubbed :citation, forms: 'w.' }
      let(:protonym) { build_stubbed :protonym, authorship: citation }

      specify do
        expect(protonym.decorate.format_pages_and_forms).to eq "#{protonym.authorship.pages} (#{citation.forms})"
      end
    end
  end
end
