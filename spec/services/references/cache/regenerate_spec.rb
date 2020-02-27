require 'rails_helper'

describe References::Cache::Regenerate do
  describe "#call" do
    let!(:reference) { create :article_reference, title: 'Old title' }

    it "regenerates caches" do
      formatter = ReferenceFormatter.new(reference)

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
      it 'invalidates them before regenerating' do
        expect(reference.plain_text_cache).to eq nil

        described_class[reference]
        expect(reference.plain_text_cache).to include 'Old title'
        expect(reference.plain_text_cache).to_not include 'New title'

        reference.update_columns(title: 'New title')
        expect(reference.plain_text_cache).to include 'Old title'
        expect(reference.plain_text_cache).to_not include 'New title'

        described_class[reference]
        expect(reference.plain_text_cache).to_not include 'Old title'
        expect(reference.plain_text_cache).to include 'New title'
      end
    end
  end
end
