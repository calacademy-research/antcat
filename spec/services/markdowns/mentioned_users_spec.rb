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
  end
end
