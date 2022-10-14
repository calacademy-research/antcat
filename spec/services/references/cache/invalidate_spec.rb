# frozen_string_literal: true

require 'rails_helper'

describe References::Cache::Invalidate do
  describe "#call" do
    let(:reference) { create :any_reference }

    it "nilifies caches" do
      References::Cache::Regenerate[reference]
      expect(reference.plain_text_cache).not_to eq nil
      expect(reference.expanded_reference_cache).not_to eq nil

      described_class[reference]

      expect(reference.plain_text_cache).to eq nil
      expect(reference.expanded_reference_cache).to eq nil
    end

    context "when reference has nested references" do
      let!(:nested_reference) { create :nested_reference, nesting_reference: reference }

      it "nilifies caches for its nested references" do
        expect(reference.reload.nested_references).to eq [nested_reference]

        References::Cache::Regenerate[nested_reference]
        expect(nested_reference.plain_text_cache).not_to eq nil
        expect(nested_reference.expanded_reference_cache).not_to eq nil

        described_class[reference]
        nested_reference.reload

        expect(nested_reference.plain_text_cache).to eq nil
        expect(nested_reference.expanded_reference_cache).to eq nil
      end
    end
  end
end
