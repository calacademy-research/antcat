require 'spec_helper'


describe ChangesController do
  describe "check that we can find and report the entire undo set" do
    it "should return a single taxon when no others would be deleted" do
      adder = FactoryGirl.create :user, can_edit: true
      taxon = create_taxon_version_and_change :waiting, adder
      taxon.save
      change_id = Change.all.first.id

      get :undo_items, id: change_id
      changes=JSON.parse(response.body)
      expect(changes).to have(1).item
      changes[0]['name'].should == 'Genus1'
      changes[0]['change_type'].should == 'create'
    end

    it "should return multiple items when undoing an older change would hit newer changes" do
      adder = FactoryGirl.create :user, can_edit: true
      taxon = create_taxon_version_and_change :waiting, adder
      taxon.save
      change = FactoryGirl.build :change, user_changed_taxon_id: taxon.id, change_type: "update"
      version = FactoryGirl.build :version, item_id: taxon.id, whodunnit: adder
      FactoryGirl.create :transaction, paper_trail_version: version, change: change


      taxon.status = 'homonym'
      taxon.save
      change_id = Change.all.first.id

      get :undo_items, id: change_id
      changes=JSON.parse(response.body)

      expect(changes).to have(2).items
      changes[0]['name'].should == 'Genus1'
      changes[0]['change_type'].should == 'create'
      changes[0]['change_timestamp'].should_not be nil
      changes[0]['user_name'].should == 'Mark Wilden'


      changes[1]['name'].should == 'Genus1'
      changes[1]['change_type'].should == 'update'
    end


  end
end
