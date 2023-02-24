# frozen_string_literal: true

require 'rails_helper'

feature "Browse", as: :helper do
  scenario "Visiting a user's page" do
    create :user, email: "quintus@antcat.org", name: "Quintus"

    visit users_path
    i_follow "Quintus"
    i_should_see "Name: Quintus"
    i_should_see "Email: quintus@antcat.org"
    i_should_see "Quintus's most recent activity"
    i_should_see "No activities"
    i_should_see "Quintus's most recent comments"
    i_should_see "No comments"
  end

  scenario "See user's most recent feed activities" do
    user = create(:user, name: "Batiatus")
    create :activity, event: :destroy, trackable: create(:journal), user: user

    visit user_path(user)
    i_should_see "Batiatus's most recent activity"
    i_should_see "Batiatus deleted the journal"
  end

  scenario "See user's most recent comments" do
    # User commented on an issue.
    user = create(:user, name: "Batiatus")
    Comment.build_comment(create(:issue, title: "Typos"), user, body: "Cool").save!

    visit user_path(user)
    i_should_see "Batiatus's most recent comments"
    i_should_see "Batiatus commented on the issue Typos:"
  end
end
