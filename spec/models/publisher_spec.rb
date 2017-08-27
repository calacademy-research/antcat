require 'spec_helper'

describe Publisher do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to belong_to :place }

  describe "factory methods" do
    describe ".create_with_place" do
      context "valid" do
        it "creates and returns the publisher" do
          publisher = described_class.create_with_place name: 'Wiley', place: 'Chicago'
          expect(publisher.name).to eq 'Wiley'
          expect(publisher.place.name).to eq 'Chicago'
        end

        it "reuses existing publishers" do
          2.times { described_class.create_with_place name: 'Wiley', place: 'Chicago' }
          expect(described_class.count).to eq 1
        end
      end

      context "invalid" do
        context "when name is supplied but no place" do
          it "raises" do
            expect { described_class.create_with_place(name: 'Wiley') }
              .to raise_error ArgumentError
          end
        end

        context "when place is invalid" do
          it "raises" do
            expect { described_class.create_with_place(name: "A Name", place: "") }
              .to raise_error ActiveRecord::RecordInvalid
          end
        end

        context "when place is blank" do
          it "silently returns without raising" do
            expect(described_class.create_with_place name: "", place: "A Place").to be nil
            expect { described_class.create_with_place name: "", place: "A Place" }
              .to_not raise_error ActiveRecord::RecordInvalid
          end
        end
      end
    end

    describe ".create_with_place_form_string" do
      it "handles blank strings" do
        expect(described_class).not_to receive :create_with_place
        described_class.create_with_place_form_string ''
      end

      it "parses" do
        expected = described_class.create_with_place_form_string 'New York: Houghton Mifflin'
        expect(expected.to_s).to eq 'New York: Houghton Mifflin'
      end
    end
  end

  # TODO used only in specs?
  describe "#to_s" do
    it "format name and place" do
      publisher = described_class.create! name: "Wiley", place: Place.create!(name: 'New York')
      expect(publisher.to_s).to eq 'New York: Wiley'
    end

    it "formats correctly even if there is no place" do
      publisher = described_class.create! name: "Wiley"
      expect(publisher.to_s).to eq 'Wiley'
    end
  end
end
