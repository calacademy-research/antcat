require 'spec_helper'

describe TaxonHistoryItem do
  it "can't be blank" do
    expect(TaxonHistoryItem.new).not_to be_valid
    expect(TaxonHistoryItem.new(taxt: '')).not_to be_valid
  end
  it "should have some taxt" do
    item = TaxonHistoryItem.new taxt: 'taxt'
    expect(item).to be_valid
    item.save!
    item.reload
    expect(item.taxt).to eq('taxt')
  end
  it "can belong to a taxon" do
    taxon = create :family
    item = taxon.history_items.create! taxt: 'foo'
    expect(item.reload.taxon).to eq(taxon)
  end

  describe "Updating taxt from editable taxt" do
    let(:item) {create :taxon_history_item}

    it "should not blow up on blank input but should be invalid and have errors" do
      item.update_taxt_from_editable ''
      expect(item.errors).not_to be_empty
      expect(item.taxt).to eq('')
      expect(item).not_to be_valid
    end

    it "should pass non-tags straight through" do
      item.update_taxt_from_editable 'abc'
      expect(item.reload.taxt).to eq('abc')
    end

    it "should convert from editable tags to tags" do
      reference = create :article_reference
      other_reference = create :article_reference
      editable_key = Taxt.id_for_editable reference.id, 1
      other_editable_key = Taxt.id_for_editable other_reference.id, 1

      item.update_taxt_from_editable %{{Fisher, 1922 #{editable_key}}, also {Bolton, 1970 #{other_editable_key}}}
      expect(item.reload.taxt).to eq("{ref #{reference.id}}, also {ref #{other_reference.id}}")
    end

    it "should have errors if a reference isn't found" do
      expect(item.errors).to be_empty
      item.update_taxt_from_editable '{123}'
      expect(item.errors).not_to be_empty
    end

  end

  describe "Versioning" do
    it "should record versions" do
      with_versioning do
        history_item = create :taxon_history_item
        expect(history_item.versions.last.event).to eq('create')
      end
    end
  end

end
