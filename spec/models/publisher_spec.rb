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

  describe ".find_or_initialize_from_string" do
    context "when invalid" do
      context "when string is blank" do
        specify do
          expect(described_class.find_or_initialize_from_string('')).to eq nil
        end
      end

      context "when name or place is missing" do
        specify do
          expect(described_class.find_or_initialize_from_string('Wiley')).to eq nil
        end
      end
    end

    context "when valid" do
      it "initializes a publisher" do
        publisher = described_class.find_or_initialize_from_string 'New York: Houghton Mifflin'
        expect(publisher.name).to eq 'Houghton Mifflin'
        expect(publisher.place).to eq 'New York'
      end

      context "when name/place combination already exists" do
        it "reuses existing publisher" do
          existing_publisher = described_class.find_or_initialize_from_string("Wiley: Chicago").tap(&:save!)
          expect(described_class.find_or_initialize_from_string("Wiley: Chicago")).to eq existing_publisher
        end
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
