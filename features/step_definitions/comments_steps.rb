When /^I write a new comment "([^"]*)"$/ do |text|
  first("#comment_body").set text
end

When /^I write a reply with the text "([^"]*)"$/ do |text|
  all("#comment_body").last.set text
end
