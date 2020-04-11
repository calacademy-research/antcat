# frozen_string_literal: true

require 'rails_helper'

describe Publisher do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to have_many(:references).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :place }

    describe "uniqueness validation" do
      subject { create :publisher }

      it { is_expected.to validate_uniqueness_of(:name).scoped_to(:place).ignoring_case_sensitivity }
    end
  end

  describe ".place_and_name_from_string" do
    context "when invalid" do
      context "when string is blank" do
        it "returns blanks for place and name" do
          expect(described_class.place_and_name_from_string('')).to eq(place: nil, name: nil)
        end
      end

      context "when name or place is missing" do
        it "returns blanks for place and name" do
          expect(described_class.place_and_name_from_string('Wiley')).to eq(place: nil, name: nil)
        end
      end
    end

    context "when valid" do
      it "returns the place and name" do
        expect(described_class.place_and_name_from_string('New York: Houghton Mifflin')).
          to eq(place: 'New York', name: 'Houghton Mifflin')
      end
    end
  end

  describe "#display_name" do
    let(:publisher) { build_stubbed :publisher, name: "Wiley", place: 'New York' }

    specify do
      expect(publisher.display_name).to eq 'New York: Wiley'
    end
  end
end
