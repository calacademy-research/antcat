# coding: UTF-8
require 'spec_helper'

describe Subgenus do

  it "must have a genus" do
    colobopsis = FactoryGirl.build :subgenus, name: FactoryGirl.create(:name, name: 'Colobopsis'), genus: nil
    FactoryGirl.create :taxon_state, taxon_id: colobopsis.id

    expect(colobopsis).not_to be_valid
    colobopsis.genus = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Camponotus')

    colobopsis.save!
    expect(colobopsis.reload.genus.name.to_s).to eq('Camponotus')
  end

  describe "Statistics" do
    it "should have none" do
      expect(FactoryGirl.create(:subgenus).statistics).to be_nil
    end
  end

  describe "Species group descendants" do
    before do
      @subgenus = create_subgenus 'Subdolichoderus'
    end
    it "should return an empty array if there are none" do
      expect(@subgenus.species_group_descendants).to eq([])
    end
    it "should return all the species" do
      species = create_species subgenus: @subgenus
      expect(@subgenus.species_group_descendants).to eq([species])
    end
  end
end