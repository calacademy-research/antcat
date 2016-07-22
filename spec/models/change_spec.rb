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
    create :version, item_id: genus.id, change_id: change.id

    genus_version = genus.last_version

    expect(change.versions.first).to eq genus_version
  end

  it "has a user (the editor)", pending: true do
    pending "Not implemented change::user"

    user = create :user
    genus = create_genus

    change = setup_version genus.id, user

    genus.last_version.update_attributes whodunnit: user.id

    expect(change.user).to eq user
  end

  it "should be able to be reified after being created", pending: true do
    pending "Not implemented change::user"

    genus = create_genus
    change = setup_version genus.id
    taxon = change.reify
    expect(taxon).to eq genus
    expect(taxon.class).to eq Genus

    genus.update_attributes name_cache: 'Atta'

    change = setup_version genus.id

    taxon = change.reify
    expect(taxon).to eq genus
    expect(taxon.class).to eq Genus
  end

  it "has a taxon", pending: true do
    pending "Not updated for new paper trail strategy"

    taxon = create_genus
    change = Change.new paper_trail_version: taxon.last_version
    expect(change.taxon).to eq taxon
  end

  describe "Scopes" do
    describe "#waiting" do
      it "returns unreviewed changes" do
        item = create_genus
        item.taxon_state.update_attributes review_state: 'waiting'
        unreviewed_change = setup_version item.id

        item = create_genus
        item.taxon_state.update_attributes review_state: 'approved'
        approved_earlier_change = setup_version item.id
        approved_earlier_change.update_attributes(approved_at: Date.today - 7)

        item = create_genus
        item.taxon_state.update_attributes review_state: 'approved'
        approved_later_change = setup_version item.id
        approved_later_change.update_attributes(approved_at: Date.today + 7)

        expect(Change.waiting).to eq [unreviewed_change]
      end
    end
  end
end
