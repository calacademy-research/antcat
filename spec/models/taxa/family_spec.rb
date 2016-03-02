require 'spec_helper'

describe Family do
  describe "Statistics" do
    it "should return the statistics for each status of each rank" do
      family = FactoryGirl.create :family
      subfamily = FactoryGirl.create :subfamily
      tribe = FactoryGirl.create :tribe, subfamily: subfamily
      genus = FactoryGirl.create :genus, :subfamily => subfamily, :tribe => tribe
      FactoryGirl.create :genus, :subfamily => subfamily, :status => 'homonym', :tribe => tribe
      2.times { FactoryGirl.create :subfamily, :fossil => true }
      expect(family.statistics).to eq({
                                          :extant => {subfamilies: {'valid' => 1}, tribes: {'valid' => 1}, genera: {'valid' => 1, 'homonym' => 1}},
                                          :fossil => {subfamilies: {'valid' => 2}}
                                      })
    end
  end

  describe "Label" do
    it "should be the family name" do
      expect(FactoryGirl.create(:family, name: FactoryGirl.create(:name, name: 'Formicidae')).name.to_html).to eq('Formicidae')
    end
  end

  describe "Genera" do
    it "should include genera without subfamilies" do
      family = create_family
      subfamily = create_subfamily
      genus_without_subfamily = create_genus subfamily: nil
      genus_with_subfamily = create_genus subfamily: subfamily
      expect(family.genera).to eq([genus_without_subfamily])
    end
  end

  describe "Subfamilies" do
    it "should include all the subfamilies" do
      family = create_family
      subfamily = create_subfamily
      expect(family.subfamilies).to eq([subfamily])
    end
  end

end