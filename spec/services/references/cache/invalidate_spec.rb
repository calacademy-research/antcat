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

    context "when reference has nestees" do
      let!(:nestee) { create :nested_reference, nesting_reference: reference }

      it "nilifies caches for its nestees" do
        expect(reference.reload.nestees).to eq [nestee]

        References::Cache::Regenerate[nestee]
        expect(nestee.plain_text_cache).not_to eq nil
        expect(nestee.expanded_reference_cache).not_to eq nil

        described_class[reference]
        nestee.reload

        expect(nestee.plain_text_cache).to eq nil
        expect(nestee.expanded_reference_cache).to eq nil
      end
    end
  end
end
