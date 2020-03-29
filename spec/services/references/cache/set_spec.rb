# frozen_string_literal: true

require 'rails_helper'

describe References::Cache::Set do
  describe "#call" do
    let!(:reference) { create :any_reference }

    it "gets and sets the right values" do
      described_class[reference, 'Cache', :plain_text_cache]
      reference.reload

      expect(reference.plain_text_cache).to eq 'Cache'
    end
  end
end
