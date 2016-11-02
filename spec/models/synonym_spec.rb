require 'spec_helper'

describe Synonym do
  it { should be_versioned }
  it { should validate_presence_of :junior_synonym }

  describe "#find_or_create" do
    let!(:junior) { create_species }
    let!(:senior) { create_species }

    context "synonym exists" do
      it "returns the existing synonym" do
        Synonym.create! junior_synonym: junior, senior_synonym: senior
        expect(Synonym.count).to eq 1

        synonym = Synonym.where(junior_synonym_id: junior, senior_synonym_id: senior)
        expect(synonym.count).to eq 1

        Synonym.find_or_create junior, senior
        expect(Synonym.count).to eq 1

        synonym = Synonym.where(junior_synonym_id: junior, senior_synonym_id: senior)
        expect(synonym.count).to eq 1
      end
    end

    context "synonym doesn't exist" do
      it "creates it" do
        Synonym.find_or_create junior, senior
        expect(Synonym.count).to eq 1

        synonym = Synonym.where(junior_synonym_id: junior, senior_synonym_id: senior)
        expect(synonym.count).to eq 1
      end
    end
  end
end
