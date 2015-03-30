# coding: UTF-8
require 'spec_helper'

describe Change do
  before do
    @was_enabled = PaperTrail.enabled?
    PaperTrail.enabled = true
  end
  after do
    PaperTrail.enabled = @was_enabled
  end

  it "has a version" do
    genus = create_genus
    change = Change.new
    change.save!
    change.reload
    FactoryGirl.create :version, item_id: genus.id, change_id: change.id


    genus_version = genus.last_version

    expect(change.versions.first).to eq(genus_version)
  end

  it "has a user (the editor)" do
    pending "Not implemented change::user"

    user = FactoryGirl.create :user
    genus = create_genus

    change = setup_version(genus.id, user)

    genus.last_version.update_attributes whodunnit: user.id

    expect(change.user).to eq(user)
  end

  it "should be able to be reified after being created" do
    pending "Not implemented change::user"

    genus = create_genus
    change = setup_version(genus.id)
    taxon = change.reify
    expect(taxon).to eq(genus)
    expect(taxon.class).to eq(Genus)

    genus.update_attributes name_cache: 'Atta'

    change = setup_version(genus.id)

    taxon = change.reify
    expect(taxon).to eq(genus)
    expect(taxon.class).to eq(Genus)
  end

  it "has a taxon" do
    pending ("Not updated for new paper trail strategy")

    taxon = create_genus
    change = Change.new paper_trail_version: taxon.last_version
    expect(change.taxon).to eq(taxon)
  end

  describe "Scopes" do

    it "should return creations" do
      item = create_genus
      creation = setup_version(item.id)
      setup_version(item.id)

      expect(Change.creations.last.id).to eq(creation.id)
    end

    it "should return creations with unapproved first, then approved in reverse chronological order" do
      pending ("Not updated for new paper trail strategy")

      item = create_genus review_state: 'waiting'
      unapproved_version = FactoryGirl.create :version, event: 'create', item_id: item.id
      item = create_genus review_state: 'approved'
      approved_earlier_version = FactoryGirl.create :version, event: 'create', item_id: item.id
      item = create_genus review_state: 'approved'
      approved_later_version = FactoryGirl.create :version, event: 'create', item_id: item.id

      unapproved = Change.create approved_at: nil, paper_trail_version: unapproved_version
      approved_earlier = Change.create approved_at: Date.today - 7, paper_trail_version: approved_earlier_version
      approved_later = Change.create approved_at: Date.today + 7, paper_trail_version: approved_later_version

      expect(Change.creations.map(&:id)).to eq([unapproved.id, approved_later.id, approved_earlier.id])
    end
  end


end
