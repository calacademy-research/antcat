# frozen_string_literal: true

require 'rails_helper'

describe CachedReferenceFormatter do
  subject(:formatter) { described_class.new(reference) }

  let(:reference) { create :article_reference }

  describe "#plain_text" do
    specify { expect(formatter.plain_text.html_safe?).to eq true }

    specify do
      expect(References::Formatted::PlainText).to receive(:new).with(reference).and_call_original
      formatter.plain_text
    end
  end

  describe "#expanded_reference" do
    specify { expect(formatter.expanded_reference.html_safe?).to eq true }

    specify do
      expect(References::Formatted::Expanded).to receive(:new).with(reference).and_call_original
      formatter.expanded_reference
    end
  end

  describe "#expandable_reference" do
    specify { expect(formatter.expandable_reference.html_safe?).to eq true }

    specify do
      expect(References::Formatted::Expandable).to receive(:new).with(reference).and_call_original
      formatter.expandable_reference
    end
  end
end
