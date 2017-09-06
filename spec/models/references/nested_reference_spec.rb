require 'spec_helper'

describe NestedReference do
  it { is_expected.to validate_presence_of :year }
  it { is_expected.to validate_presence_of :pages_in }
  it { is_expected.to validate_presence_of :nesting_reference }
  it { is_expected.to allow_value(nil).for :title }

  describe "Validation" do
    it "is valid with these attributes" do
      reference = described_class.new title: 'asdf',
        author_names: [create(:author_name)],
        citation_year: '2010',
        nesting_reference: create(:reference),
        pages_in: 'Pp 2 in:'

      expect(reference).to be_valid
    end

    it "refers to an existing reference" do
      reference = create :nested_reference

      reference.nesting_reference_id = 232434
      expect(reference).not_to be_valid
    end

    it "cannot point to itself" do
      reference = create :nested_reference

      reference.nesting_reference_id = reference.id
      expect(reference).not_to be_valid
    end

    it "cannot point to something that points to itself" do
      inner_most = create :book_reference
      middle = create :nested_reference, nesting_reference: inner_most
      top = create :nested_reference, nesting_reference: middle
      middle.nesting_reference = top

      expect(middle).not_to be_valid
    end

    it "can have a nesting_reference" do
      nesting_reference = create :reference
      nestee = create :nested_reference, nesting_reference: nesting_reference

      expect(nestee.nesting_reference).to eq nesting_reference
    end
  end

  describe "#destroy" do
    let(:reference) { create :nested_reference }

    it "should not be possible to delete a nestee" do
      expect(reference.nesting_reference.destroy).to be_falsey
    end
  end
end
