require 'spec_helper'

describe References::MatchReferences do
  let(:reference_similarity) { double }

  before do
    expect(References::ReferenceSimilarity).to receive(:new).with(target, match).
      and_return(reference_similarity)
  end

  describe "#match" do
    let!(:match) { create_match 'Ward' }
    let(:target) { build_target 'Ward' }

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
      let!(:match) { create_match "Arnol'di, G." }
      let(:target) { build_target "Arnol'di" }

      before { expect(reference_similarity).to receive(:call).and_return(0.10) }

      it "handles it" do
        expect(described_class[target]).to eq [
          { similarity: 0.10, target: target, match: match }
        ]
      end
    end
  end

  def create_match author_name_name
    author_name = create :author_name, name: author_name_name
    create :reference, author_names: [author_name]
  end

  def build_target principal_author_last_name_cache
    target = Reference.new
    target.principal_author_last_name_cache = principal_author_last_name_cache
    target
  end
end
