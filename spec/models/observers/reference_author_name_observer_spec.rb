require 'spec_helper'

describe ReferenceAuthorNameObserver do
  let(:reference) { create :article_reference }

  it "should be asked to invalidate the cache when a change occurs" do
    author_name = create :author_name
    reference_author_name = create :reference_author_name, reference: reference, author_name: author_name
    expect_any_instance_of(ReferenceAuthorNameObserver).to receive :before_save
    reference_author_name.position = 4
    reference_author_name.save!
  end

  it "invalidates the cache for the reference involved when a reference_author_name is added" do
    ReferenceFormatterCache.instance.populate reference
    reference.reference_author_names.create! position: 1, author_name: create(:author_name)
    reference.reload

    expect(ReferenceFormatterCache.instance.get(reference)).to be_nil
  end

  it "invalidates the cache for the reference involved when a reference_author_name is changed" do
    reference.reference_author_names.create! position: 1, author_name: create(:author_name)
    ReferenceFormatterCache.instance.populate reference
    reference.reference_author_names.first.update_attribute :position, 1000
    reference.reload

    expect(ReferenceFormatterCache.instance.get(reference)).to be_nil
  end

  it "invalidates the cache for the reference involved when a reference_author_name is deleted" do
    reference.reference_author_names.create! position: 1, author_name: create(:author_name)
    ReferenceFormatterCache.instance.populate reference
    reference.reference_author_names.first.destroy
    reference.reload

    expect(ReferenceFormatterCache.instance.get(reference)).to be_nil
  end
end
