describe Taxon do
  let(:taxon) { build_stubbed :taxon }

  context "when status 'valid'" do
    it "is not invalid" do
      taxon.status = "valid"
      expect(taxon).not_to be_invalid
    end
  end

  it "can be unidentifiable" do
    expect(taxon).not_to be_unidentifiable
    taxon.status = 'unidentifiable'
    expect(taxon).to be_unidentifiable
    expect(taxon).to be_invalid
  end

  it "can be a collective group name" do
    expect(taxon).not_to be_collective_group_name
    taxon.status = 'collective group name'
    expect(taxon).to be_collective_group_name
    expect(taxon).to be_invalid
  end

  it "can be an ichnotaxon" do
    expect(taxon).not_to be_ichnotaxon
    taxon.ichnotaxon = true
    expect(taxon).to be_ichnotaxon
    expect(taxon).not_to be_invalid
  end

  it "can be unavailable" do
    expect(taxon).not_to be_unavailable
    expect(taxon).to be_available
    taxon.status = 'unavailable'
    expect(taxon).to be_unavailable
    expect(taxon).not_to be_available
    expect(taxon).to be_invalid
  end

  it "can be excluded from Formicidae" do
    expect(taxon).not_to be_excluded_from_formicidae
    taxon.status = 'excluded from Formicidae'
    expect(taxon).to be_excluded_from_formicidae
    expect(taxon).to be_invalid
  end

  it "can be a fossil" do
    expect(taxon).not_to be_fossil
    expect(taxon.fossil).to eq false
    taxon.fossil = true
    expect(taxon).to be_fossil
  end

  describe "#recombination?" do
    context "when name is same as protonym" do
      let!(:species) { create_species 'Atta major' }
      let!(:protonym_name) { create :species_name, name: 'Atta major' }

      it "it is not a recombination" do
        expect(species.protonym).to receive(:name).and_return protonym_name
        expect(species).not_to be_recombination
      end
    end

    context "when genus part of name is different than genus part of protonym" do
      let!(:species) { create_species 'Atta minor' }
      let!(:protonym_name) { create :species_name, name: 'Eciton minor' }

      it "it is a recombination" do
        expect(species.protonym).to receive(:name).and_return protonym_name
        expect(species).to be_recombination
      end
    end

    context "when genus part of name is same as genus part of protonym" do
      let!(:species) { create_species 'Atta minor maxus' }
      let!(:protonym_name) { create :subspecies_name, name: 'Atta minor minus' }

      it "it is not a recombination" do
        expect(species.protonym).to receive(:name).and_return protonym_name
        expect(species).not_to be_recombination
      end
    end
  end

  describe "#incertae_sedis_in" do
    let(:myanmyrma) { build_stubbed :taxon, incertae_sedis_in: 'family' }

    it "can have an incertae_sedis_in" do
      expect(myanmyrma.incertae_sedis_in).to eq 'family'
      expect(myanmyrma).not_to be_invalid
    end

    it "can say whether it is incertae sedis in a particular rank" do
      expect(myanmyrma).to be_incertae_sedis_in 'family'
    end
  end
end
