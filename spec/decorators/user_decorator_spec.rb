# frozen_string_literal: true

require 'rails_helper'

describe UserDecorator do
  subject(:decorated) { user.decorate }

  describe "#user_page_link" do
    let(:user) { build_stubbed :user }

    it "link the name to the user page" do
      expect(decorated.user_page_link).to eq %(<a href="/users/#{user.id}">#{user.name}</a>)
    end
  end

  describe "#ping_user_link" do
    let(:user) { build_stubbed :user }

    it "like `#user_page_link`, but prefixed with an '@'" do
      expect(decorated.ping_user_link).
        to eq %(<a class="user-mention" href="/users/#{user.id}">@#{user.name}</a>)
    end
  end

  describe "#angle_bracketed_email" do
    let(:user) { build_stubbed :user }

    it "builds a string suitable for emails" do
      expect(decorated.angle_bracketed_email).to eq %("#{user.name}" <#{user.email}>)
    end
  end

  describe "#user_badge" do
    context "when user is an editor" do
      let(:user) { build_stubbed :user, :editor }

      specify do
        expect(decorated.user_badge).
          to eq %(<span class="label rounded-badge">editor <i class="antcat_icon star"></i></span>)
      end
    end

    context "when user is a helper" do
      let(:user) { build_stubbed :user, :helper }

      specify do
        expect(decorated.user_badge).
          to eq %(<span class="white-label rounded-badge">helper <i class="antcat_icon black-star"></i></span>)
      end
    end

    context "when user is neither an editor nor a helper" do
      let(:user) { build_stubbed :user }

      specify { expect(decorated.user_badge).to eq nil }
    end
  end
end
