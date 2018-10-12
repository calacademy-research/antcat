require 'spec_helper'

describe References::FindDuplicates do
  let(:reference_similarity) { double }

  before do
    expect(References::ReferenceSimilarity).to receive(:new).with(target, match).
      and_return(reference_similarity)
  end

  describe "#call" do
    let!(:match) { create :reference, author_name: 'Ward, P.S.' }
    let(:target) { create :reference, author_name: 'Ward' }

    context "when an obvious mismatch" do
      before { expect(reference_similarity).to receive(:call).and_return(0.00) }

      it "doesn't match" do
        expect(described_class[target]).to be_empty
      end
    end

    context "when an obvious match" do
      before { expect(reference_similarity).to receive(:call).and_return(0.10) }

      it "matches" do
        expect(described_class[target]).to eq [
          { similarity: 0.10, target: target, match: match }
        ]
      end
    end

    context "with an author last name with an apostrophe in it (regression)" do
      let!(:match) { create :reference, author_name: "Arnol'di, G." }
      let(:target) { create :reference, author_name: "Arnol'di" }

      before { expect(reference_similarity).to receive(:call).and_return(0.10) }

      it "handles it" do
        expect(described_class[target]).to eq [
          { similarity: 0.10, target: target, match: match }
        ]
      end
    end
  end
end
