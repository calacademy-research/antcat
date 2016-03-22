# "for the feed" is basically namespacing.

Given /^activity tracking is (enabled|disabled)$/ do |state|
  new_state = case state
              when "enabled" then true
              when "disabled" then false
              else raise end
  Feed::Activity.enabled = new_state
end

Then /^I should see "([^"]*)" and no other feed items$/ do |text|
  step %Q[I should see "#{text}"]
  step %Q[I should see 1 item in the feed]
end

Then /^I should see (\d+) items? in the feed$/ do |expected_count|
  actual_count = all("table.feed > tbody tr").size
  expect(actual_count).to eq expected_count.to_i
end

# Journal
When /^I add a journal for the feed$/ do
  Journal.create name: "Archibald Bulletin"
end

When /^I edit a journal for the feed$/ do
  journal = Feed::Activity.without_tracking do
    Journal.create name: "Archibald Bulletin"
  end
  journal.name = "New Journal Name"
  journal.save!
end

When /^I delete a journal for the feed$/ do
  journal = Feed::Activity.without_tracking do
    Journal.create name: "Archibald Bulletin"
  end
  journal.destroy
end

# TaxonHistoryItem
When /^I add a taxon history item for the feed$/ do
  taxon = Feed::Activity.without_tracking { create_subfamily }

  TaxonHistoryItem.create taxt: "as a subfamily: {ref 123}",
    taxon: taxon
end

When /^I edit a taxon history item for the feed$/ do
  item = Feed::Activity.without_tracking do
    TaxonHistoryItem.create taxt: "as a subfamily: {ref 123}",
      taxon: create_subfamily
  end
  item.taxt = "as a genus: {ref 123}"
  item.save!
end

When /^I delete a taxon history item for the feed$/ do
  item = Feed::Activity.without_tracking do
    TaxonHistoryItem.create taxt: "as a subfamily: {ref 123}",
      taxon: create_subfamily
  end
  item.destroy
end

# Reference
Given /^there is a reference for the feed with state "(.*?)"$/ do |state|
  Feed::Activity.without_tracking do
    reference = create :article_reference,
      author_names: [create(:author_name, name: 'Giovanni, S.')],
      citation_year: '1809',
      title: "Giovanni's Favorite Ants",
      review_state: state
  end
end

When /^I create a bunch of references for the feed$/ do
  Feed::Activity.without_tracking do
    create :article_reference, review_state: "reviewing"
    create :article_reference, review_state: "reviewing"
    create :article_reference, review_state: "reviewed"
  end
end

# Tooltip
Given /^there is a tooltip for the feed$/ do
  Feed::Activity.without_tracking do
    Tooltip.create key: "authors", scope: "taxa", text: "Text"
  end
end

# Task
Given /^there is an open task for the feed$/ do
  Feed::Activity.without_tracking do
    create :open_task, title: "Valid?"
  end
end

Given /^there is a closed task for the feed$/ do
  Feed::Activity.without_tracking do
    create :closed_task, title: "Valid?"
  end
end

# Taxon
When /^I add a taxon for the feed$/ do
  Feed::Activity.without_tracking do
    step "the Formicidae family exists"
    subfamily_name = create :subfamily_name, name: "Antcatinae"
    create :subfamily, name: subfamily_name
  end
end
