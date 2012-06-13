# coding: UTF-8
require 'spec_helper'

describe ForwardReference do

  describe "Fixing up" do
    describe "Fixing up all forward references" do
      it "should do nothing if the table is empty" do
        ForwardReference.fixup
      end

      it "should call each's fixup method" do
        first = mock
        second = mock
        ForwardReference.should_receive(:all).and_return [first, second]
        first.should_receive(:fixup)
        second.should_receive(:fixup)

        ForwardReference.fixup
      end
    end

    describe "Fixing up one reference" do

      it "should fixup a senior synonym" do
        genus = FactoryGirl.create :genus
        species_name = FactoryGirl.create(:species_name, name: 'minor', genus_group_name: genus.name)
        junior_synonym = FactoryGirl.create :species, genus: genus
        senior_synonym = FactoryGirl.create :species, name: species_name, genus: genus
        forward_reference = ForwardReference.create! :source_id => junior_synonym.id, :target_name => 'minor', target_parent: genus.id
        forward_reference.fixup
        junior_synonym.reload
        junior_synonym.should be_synonym_of senior_synonym
      end

    end
  end

end
