# "for the feed" is basically namespacing.
# TODO DRY

# Journal
When /^I add a journal for the feed$/ do
  Journal.create name: "Archibald Bulletin"
end

When /^I edit a journal for the feed$/ do
  journal = Journal.create name: "Archibald Bulletin"
  journal.name = "New Journal Name"
  journal.save!
end

When /^I delete a journal for the feed$/ do
  journal = Journal.create name: "Archibald Bulletin"
  journal.destroy
end

# TaxonHistoryItem
When /^I add a taxon history item for the feed$/ do
  TaxonHistoryItem.create taxt: "as a subfamily: {ref 123}",
    taxon: create_subfamily
end

When /^I edit a taxon history item for the feed$/ do
  item = TaxonHistoryItem.create taxt: "as a subfamily: {ref 123}",
    taxon: create_subfamily
  item.taxt = "as a genus: {ref 123}"
  item.save!
end

When /^I delete a taxon history item for the feed$/ do
  item = TaxonHistoryItem.create taxt: "as a subfamily: {ref 123}",
    taxon: create_subfamily
  item.destroy
end
