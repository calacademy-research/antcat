# frozen_string_literal: true

require 'rails_helper'

describe Authors::FindOrInitializeNamesFromString do
  describe "#call" do
    describe 're-using and creating names' do
      let!(:bolton) { AuthorName.create!(name: 'Bolton, B.', author: Author.create!) }

      it "finds or initializes authors with names" do
        author_names = described_class['Ward, P.S.; Bolton, B.']

        expect(author_names.map(&:name)).to eq ['Ward, P.S.', 'Bolton, B.']
        expect(author_names.second.author).to eq bolton.author
        expect(author_names.second).to eq bolton
        expect(author_names.second.persisted?).to eq true
      end
    end

    describe 'where there exist author names with different capitalization' do
      before do
        AuthorName.create!(name: 'bolton, B.', author: Author.create!)
      end

      it "considers them as different" do
        author_names = described_class['Ward, P.S.; Bolton, B.']

        expect(author_names.map(&:name)).to eq ['Ward, P.S.', 'Bolton, B.']
        expect(author_names.second.persisted?).to eq false
      end
    end

    context 'when there are suffixes' do
      it "ignores them" do
        author_names = described_class['Bolton, B. (eds.)']
        expect(author_names.map(&:name)).to eq ['Bolton, B.']
      end
    end

    context 'when input is invalid' do
      it "returns an empty array" do
        author_names = described_class[' ; ']
        expect(author_names).to eq []
      end
    end

    context 'when the last semicolon is followed by a space' do
      it "ignores it" do
        author_names = described_class['Ward, P. S.; ']
        expect(author_names.map(&:name)).to eq ["Ward, P. S."]
      end
    end
  end
end
