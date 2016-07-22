require 'spec_helper'

describe ReferenceAuthorNameObserver do
  it "should be asked to invalidate the cache when a change occurs" do
    reference = create :article_reference
    author_name = create :author_name
    reference_author_name = create :reference_author_name, reference: reference, author_name: author_name
    expect_any_instance_of(ReferenceAuthorNameObserver).to receive :before_save
    reference_author_name.position = 4
    reference_author_name.save!
  end

  it "should invalidate the cache for the reference involved when a reference_author_name is added" do
    reference = create :article_reference
    ReferenceFormatterCache.instance.populate reference
    reference.reference_author_names.create! position: 1, author_name: create(:author_name)
    expect(ReferenceFormatterCache.instance.get(reference)).to be_nil
  end

  it "should invalidate the cache for the reference involved when a reference_author_name is changed" do
    reference = create :article_reference
    reference.reference_author_names.create! position: 1, author_name: create(:author_name)
    ReferenceFormatterCache.instance.populate reference
    reference.reference_author_names.first.update_attribute :position, 1000
    expect(ReferenceFormatterCache.instance.get(reference)).to be_nil
  end

  it "should invalidate the cache for the reference involved when a reference_author_name is deleted" do
    reference = create :article_reference
    reference.reference_author_names.create! position: 1, author_name: create(:author_name)
    ReferenceFormatterCache.instance.populate reference
    reference.reference_author_names.first.destroy
    expect(ReferenceFormatterCache.instance.get(reference)).to be_nil
  end
end
