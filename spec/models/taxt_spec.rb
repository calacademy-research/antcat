# frozen_string_literal: true

require 'rails_helper'

describe Taxt do
  describe '.to_ref_tag' do
    let(:reference) { create :any_reference }

    it 'generates a taxt tag for the reference' do
      expect(described_class.to_ref_tag(reference)).to eq "{ref #{reference.id}}"
    end
  end
end
