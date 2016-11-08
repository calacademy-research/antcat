require 'spec_helper'

describe Protonym do
  it { should be_versioned }
  it { should validate_presence_of :authorship }

  describe "#authorship" do
    it "has an authorship" do
      authorship = create :citation
      protonym = Protonym.create! name: create(:name, name: 'Protonym'), authorship: authorship

      expect(Protonym.find(protonym.id).authorship).to eq authorship
    end
  end

  describe "#authorship_string" do
    context "there is no citation" do
      it "handles it" do
        protonym = build_stubbed :protonym, authorship: nil
        expect(protonym.authorship_string).to be_nil
      end
    end

    it "delegates to the citation" do
      citation = build_stubbed :citation
      protonym = build_stubbed :protonym, authorship: citation

      expect(citation).to receive(:authorship_string).and_return 'Bolton 2005'
      expect(protonym.authorship_string).to eq 'Bolton 2005'
    end
  end

  describe "#author_last_names_string" do
    context "there is no citation" do
      it "handles it" do
        protonym = build_stubbed :protonym, authorship: nil
        expect(protonym.author_last_names_string).to be_nil
      end
    end

    it "delegates to the citation" do
      citation = build_stubbed :citation
      protonym = build_stubbed :protonym, authorship: citation

      expect(citation).to receive(:author_last_names_string).and_return 'Bolton'
      expect(protonym.author_last_names_string).to eq 'Bolton'
    end
  end

  describe "#year" do
    context "there is no citation" do
      it "handles it" do
        protonym = build_stubbed :protonym, authorship: nil
        expect(protonym.year).to be_nil
      end
    end

    it "delegates to the citation" do
      citation = build_stubbed :citation
      protonym = build_stubbed :protonym, authorship: citation

      expect(citation).to receive(:year).and_return '2010'
      expect(protonym.year).to eq '2010'
    end
  end

  describe "#destroy" do
    describe "Cascading delete" do
      it "deletes the citation when the protonym is deleted" do
        protonym = create :protonym

        expect(Protonym.count).to eq 1
        expect(Citation.count).to eq 1

        protonym.destroy
        expect(Protonym.count).to be_zero
        expect(Citation.count).to be_zero
      end
    end
  end
end
