# "for the feed" is basically namespacing.

When /^I add a journal for the feed$/ do
  Journal.create name: "Archibald Journal"
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
