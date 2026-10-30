# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::TaxaWithSameNameAndStatus do
  let(:script) { described_class.new }

  it "lists taxa that share both name and status, as pairs" do
    valid_1 = create :species, :valid, name_string: 'Atta x'
    valid_2 = create :species, :valid, name_string: 'Atta x'
    create :species, :synonym, name_string: 'Atta x'
    synonym_1 = create :species, :synonym, name_string: 'Lasius y'
    synonym_2 = create :species, :synonym, name_string: 'Lasius y'

    expect(script.results).to match_array [valid_1, valid_2, synonym_1, synonym_2]
  end
end
