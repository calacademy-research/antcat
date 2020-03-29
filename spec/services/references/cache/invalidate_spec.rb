# frozen_string_literal: true

require 'rails_helper'

describe References::Cache::Invalidate do
  describe "#call" do
    let(:reference) { create :any_reference }

    it "nilifies caches" do
      References::Cache::Regenerate[reference]
      expect(reference.plain_text_cache).not_to eq nil
      expect(reference.expandable_reference_cache).not_to eq nil
      expect(reference.expanded_reference_cache).not_to eq nil

      described_class[reference]
      expect(reference.plain_text_cache).to eq nil
      expect(reference.expandable_reference_cache).to eq nil
      expect(reference.expanded_reference_cache).to eq nil
    end
  end
end
