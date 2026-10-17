# frozen_string_literal: true

require 'rails_helper'

describe Markdowns::MentionedUsers do
  describe "#call" do
    let!(:user_1) { create :user }
    let!(:user_2) { create :user }

    it "returns existing mentioned users without duplicates" do
      expect(described_class[<<-STRING]).to eq [user_1, user_2]
        Hello @user#{user_1.id}, @user#{user_2.id} and @user#{user_2.id}.
        Please call @user9999
      STRING
    end

    it "ignores locked and deleted users" do
      locked_user = create :user, locked: true
      deleted_user = create :user, deleted: true

      content = "@user#{user_1.id} @user#{locked_user.id} @user#{deleted_user.id}"
      expect(described_class[content]).to eq [user_1]
    end

    it "only returns the first #{described_class::MAX_MENTIONED_USERS} distinct users mentioned" do
      other_users = described_class::MAX_MENTIONED_USERS.times.map { create :user }
      content = [user_1, *other_users, user_2].map { |user| "@user#{user.id}" }.join(' ')

      result = described_class[content]
      expect(result.size).to eq described_class::MAX_MENTIONED_USERS
      expect(result).to include user_1
      expect(result).not_to include user_2
    end
  end
end
