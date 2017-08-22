require 'spec_helper'

describe Publisher do
  it { should be_versioned }
  it { should validate_presence_of :name }
  it { should belong_to :place }

  describe "factory methods" do
    describe ".create_with_place" do
      context "valid" do
        it "creates and returns the publisher" do
          publisher = Publisher.create_with_place name: 'Wiley', place: 'Chicago'
          expect(publisher.name).to eq 'Wiley'
          expect(publisher.place.name).to eq 'Chicago'
        end

        it "reuses existing publishers" do
          2.times { Publisher.create_with_place name: 'Wiley', place: 'Chicago' }
          expect(Publisher.count).to eq 1
        end
      end

      context "invalid" do
        it "raises if name is supplied but no place" do
          expect { Publisher.create_with_place(name: 'Wiley') }
            .to raise_error ArgumentError
        end

        it "raises if place is invalid" do
          expect { Publisher.create_with_place(name: "A Name", place: "") }
            .to raise_error ActiveRecord::RecordInvalid
        end

        it "silently returns without raising if place is blank" do
          expect(Publisher.create_with_place name: "", place: "A Place").to be nil
          expect { Publisher.create_with_place name: "", place: "A Place" }
            .to_not raise_error ActiveRecord::RecordInvalid
        end
      end
    end

    describe ".create_with_place_form_string" do
      it "handles blank strings" do
        expect(Publisher).not_to receive :create_with_place
        Publisher.create_with_place_form_string ''
      end

      it "parses" do
        expected = Publisher.create_with_place_form_string 'New York: Houghton Mifflin'
        expect(expected.to_s).to eq 'New York: Houghton Mifflin'
      end
    end
  end

  # TODO used only in specs?
  describe "#to_s" do
    it "format name and place" do
      publisher = Publisher.create! name: "Wiley", place: Place.create!(name: 'New York')
      expect(publisher.to_s).to eq 'New York: Wiley'
    end

    it "formats correctly even if there is no place" do
      publisher = Publisher.create! name: "Wiley"
      expect(publisher.to_s).to eq 'Wiley'
    end
  end
end
