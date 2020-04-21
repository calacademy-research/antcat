# frozen_string_literal: true

require 'rails_helper'

describe Autocomplete::ReferencesQuery do
  context "when there are results", :search do
    let!(:reference) { create :any_reference, author_string: "Bolton" }

    before { Sunspot.commit }

    specify { expect(described_class["Bolt", {}]).to eq [reference] }
  end

  context 'when a reference ID is given' do
    let!(:reference) { create :any_reference }

    specify { expect(described_class[reference.id.to_s, {}]).to eq [reference] }
  end
end
