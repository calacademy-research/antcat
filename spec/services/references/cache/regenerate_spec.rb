# frozen_string_literal: true

require 'rails_helper'

describe References::Cache::Regenerate do
  describe "#call" do
    let!(:reference) { create :any_reference }

    it "regenerates caches" do
      formatter = References::CachedReferenceFormatter.new(reference)

      expect(reference.plain_text_cache).to eq nil
      expect(reference.expandable_reference_cache).to eq nil
      expect(reference.expanded_reference_cache).to eq nil

      described_class[reference]

      expect(reference.plain_text_cache).to_not eq nil
      expect(reference.expandable_reference_cache).to_not eq nil
      expect(reference.expanded_reference_cache).to_not eq nil

      expect(reference.plain_text_cache).to eq formatter.plain_text
      expect(reference.expandable_reference_cache).to eq formatter.expandable_reference
      expect(reference.expanded_reference_cache).to eq formatter.expanded_reference
    end

    context 'when reference has caches' do
      let(:new_title) { 'New title' }

      it 'invalidates them before regenerating' do
        described_class[reference]

        reference.update_columns(title: new_title)
        expect(reference.reload.plain_text_cache).to_not include new_title

        described_class[reference]
        expect(reference.plain_text_cache).to include new_title
      end
    end
  end
end
