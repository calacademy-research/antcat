require 'spec_helper'

describe Publisher do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :name }

  describe ".create_with_place_form_string" do
    context "when invalid" do
      context "when string is blank" do
        specify do
          expect { described_class.create_with_place_form_string('') }.to_not change { described_class.count }
        end
      end

      context "when name or place is missing" do
        specify do
          expect { described_class.create_with_place_form_string('Wiley') }.to_not change { described_class.count }
        end
      end
    end

    context "when valid" do
      it "creates a publisher" do
        publisher = described_class.create_with_place_form_string 'New York: Houghton Mifflin'
        expect(publisher.name).to eq 'Houghton Mifflin'
        expect(publisher.place_name).to eq 'New York'
      end

      context "when name/place combination already exists" do
        it "reuses existing publisher" do
          2.times { described_class.create_with_place_form_string("Wiley: Chicago") }
          expect(described_class.count).to eq 1
        end
      end
    end
  end

  describe "#display_name" do
    it "format name and place" do
      publisher = described_class.create! name: "Wiley", place_name: 'New York'
      expect(publisher.display_name).to eq 'New York: Wiley'
    end

    it "formats correctly even if there is no place" do
      publisher = described_class.create! name: "Wiley"
      expect(publisher.display_name).to eq 'Wiley'
    end
  end
end
