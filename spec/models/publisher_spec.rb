require 'spec_helper'

describe Publisher do

  it { should validate_presence_of(:name) }
  it { should belong_to(:place) }

  describe "importing" do
    describe "#import" do
      context "valid" do
        it "creates and returns the publisher" do
          publisher = Publisher.import(:name => 'Wiley', :place => 'Chicago')
          expect(publisher.name).to eq('Wiley')
          expect(publisher.place.name).to eq('Chicago')
        end

        it "reuses existing publishers" do
          2.times {Publisher.import(:name => 'Wiley', :place => 'Chicago')}
          expect(Publisher.count).to eq(1)
        end
      end

      context "invalid" do
        it "raises if name is supplied but no place" do
          expect {Publisher.import(:name => 'Wiley')}.to raise_error(ArgumentError)
        end
        it "raises if place is invalid" do
          expect { Publisher.import(name: "A Name", place: "") }.to raise_error(
            ActiveRecord::RecordInvalid)
        end
        it "silently returns without raising if place is blank" do
          expect(Publisher.import name: "", place: "A Place").to be nil
          expect { Publisher.import name: "", place: "A Place" }.to_not raise_error(
            ActiveRecord::RecordInvalid)
        end
      end
    end

    describe "#import_string" do
      it "handles blank strings" do
        expect(Publisher).not_to receive :import
        Publisher.import_string ''
      end
      it "parses" do
        publisher = mock_model Publisher
        expect(Publisher).to receive(:import).with(:name => 'Houghton Mifflin', :place => 'New York').and_return publisher
        expect(Publisher.import_string('New York: Houghton Mifflin')).to eq(publisher)
      end
    end
  end

  describe "searching" do
    it "should do fuzzy matching of name/place combinations" do
      Publisher.create! :name => 'Wiley', :place => Place.create!(:name => 'Chicago')
      Publisher.create! :name => 'Wiley', :place => Place.create!(:name => 'Toronto')
      expect(Publisher.search('chw')).to eq(['Chicago: Wiley'])
    end
    it "should find a match even if there's no place" do
      Publisher.create! :name => 'Wiley'
      expect(Publisher.search('w')).to eq(['Wiley'])
    end
  end

  describe "representing as a string" do
    it "format name and place" do
      expect(Publisher.create!(:name => "Wiley", :place => Place.create!(:name => 'New York')).to_s).to eq('New York: Wiley')
    end
    it "should format correctly if there is no place" do
      expect(Publisher.create!(:name => "Wiley").to_s).to eq('Wiley')
    end
  end

  describe "Versioning" do
    it "should record versions" do
      with_versioning do
        publisher = FactoryGirl.create :publisher
        expect(publisher.versions.last.event).to eq('create')
      end
    end
  end

end
