require 'spec_helper'

describe Subgenus do
  it { is_expected.to validate_presence_of :genus }

  describe "#ensure_correct_name_type" do
    let(:subgenus) { create :subgenus }

    context 'when Taxon and Name classes do not match' do
      let(:genus_name) { create :genus_name }

      it 'is not valid' do
        expect { subgenus.name = genus_name }.to change { subgenus.valid? }.from(true).to(false)
        expect(subgenus.errors.messages[:base].first).to include 'types must match'
      end
    end
  end

  describe "#statistics" do
    let(:subgenus) { create :subgenus }

    it "has none" do
      expect(subgenus.statistics).to be_nil
    end
  end
end
