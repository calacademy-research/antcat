# frozen_string_literal: true

require 'rails_helper'

describe Authors::Merge do
  describe '#call' do
    let!(:target_author) { create(:author_name).author }
    let!(:author_to_merge) { create(:author_name).author }

    it "makes all the names of the passed in authors belong to the same author" do
      expect(Author.count).to eq 2
      expect(AuthorName.count).to eq 2

      all_names = (target_author.names + author_to_merge.names).uniq.sort

      described_class[target_author, author_to_merge]
      expect(all_names.all? { |name| name.author == target_author }).to eq true

      expect(Author.count).to eq 1
      expect(AuthorName.count).to eq 2
    end
  end
end
