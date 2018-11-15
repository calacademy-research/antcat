require 'spec_helper'

describe Species do
  it { is_expected.to validate_presence_of :genus }

  it "can have subspecies, which are its children" do
    species = create :species
    robusta = create :subspecies, species: species
    saltensis = create :subspecies, species: species

    expect(species.subspecies).to eq [robusta, saltensis]
    expect(species.children).to eq species.subspecies
  end
end
