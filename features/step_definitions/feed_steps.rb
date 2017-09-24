Given(/^activity tracking is (enabled|disabled)$/) do |state|
  new_state = case state
              when "enabled" then true
              when "disabled" then false
              else raise end
  Feed.enabled = new_state
end

Then(/^I should see "([^"]*)" and no other feed items$/) do |text|
  step %Q[I should see "#{text}"]
  step "I should see 1 item in the feed"
end

Then(/^I should see (\d+) items? in the feed$/) do |expected_count|
  expect(feed_items_count).to eq expected_count.to_i
end

Then(/^I should see at least (\d+) items? in the feed$/) do |expected_count|
  expect(feed_items_count).to be >= expected_count.to_i
end

def feed_items_count
  all("table.activities > tbody tr").size
end

# Journal
When(/^I add a journal for the feed$/) do
  cheat_and_set_user_for_feed
  create :journal, name: "Archibald Bulletin"
end

When(/^I edit a journal for the feed$/) do
  journal = Feed.without_tracking do
    create :journal, name: "Archibald Bulletin"
  end

  cheat_and_set_user_for_feed
  journal.name = "New Journal Name"
  journal.save!
end

When(/^I delete a journal for the feed$/) do
  journal = Feed.without_tracking do
    create :journal, name: "Archibald Bulletin"
  end

  cheat_and_set_user_for_feed
  journal.destroy
end

# TaxonHistoryItem
When(/^I add a taxon history item for the feed$/) do
  taxon = Feed.without_tracking { create_subfamily }

  cheat_and_set_user_for_feed
  item = TaxonHistoryItem.create taxt: "as a subfamily: {ref 123}",
    taxon: taxon
  item.create_activity :create
end

When(/^I edit a taxon history item for the feed$/) do
  item = Feed.without_tracking do
    TaxonHistoryItem.create taxt: "as a subfamily: {ref 123}",
      taxon: create_subfamily
  end

  cheat_and_set_user_for_feed
  item.taxt = "as a genus: {ref 123}"
  item.save!
  item.create_activity :update
end

When(/^I delete a taxon history item for the feed$/) do
  item = Feed.without_tracking do
    TaxonHistoryItem.create taxt: "as a subfamily: {ref 123}",
      taxon: create_subfamily
  end

  cheat_and_set_user_for_feed
  item.destroy
  item.create_activity :destroy
end

# Reference
Given(/^there is a reference for the feed with state "(.*?)"$/) do |state|
  Feed.without_tracking do
    create :article_reference,
      author_names: [create(:author_name, name: 'Giovanni, S.')],
      citation_year: '1809',
      title: "Giovanni's Favorite Ants",
      review_state: state
  end
end

When(/^I create a bunch of references for the feed$/) do
  Feed.without_tracking do
    create :article_reference, review_state: "reviewing"
    create :article_reference, review_state: "reviewing"
    create :article_reference, review_state: "reviewed"
  end
end

# Tooltip
Given(/^there is a tooltip for the feed$/) do
  Feed.without_tracking do
    Tooltip.create key: "authors", scope: "taxa", text: "Text"
  end
end

# Issue
Given(/^there is an open issue for the feed$/) do
  Feed.without_tracking do
    create :issue, :open, title: "Valid?"
  end
end

Given(/^there is a closed issue for the feed$/) do
  Feed.without_tracking do
    create :issue, :closed, title: "Valid?"
  end
end

# Taxon
When(/^I add a taxon for the feed$/) do
  Feed.without_tracking do
    subfamily_name = create :subfamily_name, name: "Antcatinae"

    cheat_and_set_user_for_feed
    create :subfamily, name: subfamily_name
  end
end

# Change
Given(/^there are two unreviewed catalog changes for the feed$/) do
  Feed.without_tracking do
    step %{there is a genus "Cactusia" that's waiting for approval}
    step %{there is a genus "Camelia" that's waiting for approval}
  end
end

# ReferenceSection
When(/^I add a reference section for the feed$/) do
  taxon = Feed.without_tracking { create_subfamily }

  cheat_and_set_user_for_feed
  ReferenceSection.create title_taxt: "PALAEONTOLOGY",
    references_taxt: "The Ants (amber checklist)", taxon: taxon
end

When(/^I edit a reference section for the feed$/) do
  section = Feed.without_tracking do
    ReferenceSection.create title_taxt: "PALAEONTOLOGY",
    references_taxt: "The Ants (amber checklist)", taxon: create_subfamily
  end

  cheat_and_set_user_for_feed
  section.references_taxt = "The Ants (amber fossil checklist)"
  section.save!
end

When(/^I delete a reference section for the feed$/) do
  section = Feed.without_tracking do
    ReferenceSection.create title_taxt: "PALAEONTOLOGY",
    references_taxt: "The Ants (amber checklist)", taxon: create_subfamily
  end

  cheat_and_set_user_for_feed
  section.destroy
end

When(/^I click on Show more$/) do
  find("a", text: "Show more").click
end

Given(/^the activities are paginated with (\d+) per page$/) do |per_page|
  Activity.per_page = per_page.to_i
end

Given(/^there are (\d+) activity items$/) do |number|
  number.to_i.times { create :activity }
end

Then(/^the query string should (not )?contain "([^"]*)"$/) do |should_not, contain|
  match = page.current_url[contain]
  if should_not
    expect(match).to be nil
  else
    expect(match).to be_truthy
  end
end

# Execute a script
When(/^I execute a script with the content "(.*?)"$/) do |content|
  cheat_and_set_user_for_feed
  Activity.create_without_trackable :execute_script, edit_summary: content
end

# General note about RequestStore
# The gem is all good, but it makes testing harder.
#
# When JavaScript is enabled, Cucumber and the factories run in different threads,
# so it's tricky to access the request which is where the feed get's the current user,
# and `UndoTracker` gets the `current_change_id`.
#
# Many specs and steps cheat to make life easier, and that OK as long as the
# code works as intended and there are tests that doesn't cheat, but we should
# figure out how to improve this.
def cheat_and_set_user_for_feed
  User.current = User.last
end
