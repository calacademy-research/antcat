# "for the feed" is basically namespacing.
# TODO DRY

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
When /^I create a bunch of references for the feed$/ do
  Feed::Activity.without_tracking do
    create :article_reference, review_state: "reviewing"
    create :article_reference, review_state: "reviewing"
    create :article_reference, review_state: "reviewed"
  end
end
