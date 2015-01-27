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
    transaction = Transaction.new
    transaction.change = change
    genus_version = genus.last_version
    transaction.paper_trail_version = genus_version
    change.save!
    transaction.save!
    change.reload
    expect(change.paper_trail_versions.first).to eq(genus_version)
  end

  it "has a user (the editor)" do
    pending ("Not updated for new paper trail strategy")
    user = FactoryGirl.create :user
    genus = create_genus
    create_taxon_change(genus,'create',user)

    genus.last_version.update_attributes whodunnit: user.id

    change = Change.new paper_trail_version: genus.last_version
    expect(change.user).to eq(user)
  end

  it "should be able to be reified after being created" do
    pending ("Not updated for new paper trail strategy")

    genus = create_genus

    change = Change.new paper_trail_version: genus.last_version
    taxon = change.reify
    expect(taxon).to eq(genus)
    expect(taxon.class).to eq(Genus)

    genus.update_attributes name_cache: 'Atta'

    change = Change.new paper_trail_version: genus.last_version
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
    pending ("Not updated for new paper trail strategy")

    it "should return creations" do
      item = create_genus
      version = FactoryGirl.create :version, event: 'create', item_id: item.id
      creation = Change.create paper_trail_version: version
      another_version = FactoryGirl.create :version, event: 'update', item_id: item.id
      updation = Change.create paper_trail_version: another_version

      expect(Change.creations).to eq([creation])
    end
    pending ("Not updated for new paper trail strategy")

    it "should return creations with unapproved first, then approved in reverse chronological order" do
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

  def create_taxon_change (taxon, event, user)
    version = Version.create! item_id: taxon.id, event: 'create', item_type: 'Taxon', whodunnit: adder
    transaction = Transaction.create! paper_trail_version_id: version.id
    change = Change.create! user_changed_taxon_id: taxon.id
    transaction.change = change
    transaction.save
  end

end
