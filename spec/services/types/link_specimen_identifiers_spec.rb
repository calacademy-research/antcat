# frozen_string_literal: true

require 'rails_helper'

describe Types::LinkSpecimenIdentifiers do
  describe '#call' do
    it 'converts plain-text specimen identifiers to links with extra markup' do
      expect(described_class['CASENT123']).to eq <<~HTML.gsub(/\n +/, '').delete("\n")
        <span data-controller="external-preview">
          <a data-external-preview-target="link" href="https://www.antweb.org/specimen/CASENT123">
            CASENT123
          </a>
        </span>
      HTML
    end

    it "does not introduce newlines (to avoid whitespace after identifiers followed by for example periods)" do
      expect(described_class['before CASENT123 after'].count("\n")).to eq 0
    end

    it 'handles whitespace, punctuation and parentheses' do
      expect(described_class['before CASENT123 after']).to match %r{^before <span .*?><a .*?>CASENT123</a></span> after$}
      expect(described_class['before CASENT123. after']).to match %r{^before <span .*?><a .*?>CASENT123</a></span>\. after$}
      expect(described_class['before (CASENT123) after']).to match %r{^before \(<span .*?><a .*?>CASENT123</a></span>\) after$}
      expect(described_class['before MCZ-ENT123 after']).to match %r{^before <span .*?><a .*?>MCZ-ENT123</a></span> after$}
    end

    it 'respects word boundaries' do
      expect(described_class['hiCASENT123']).to eq "hiCASENT123"
    end
  end
end
