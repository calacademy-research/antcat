# frozen_string_literal: true

Then("{string} should have {int} unread email(s)") do |address, amount|
  expect(unread_emails_for(address).size).to eq parse_email_count(amount)
end

When "{string} follows {string} in the email" do |address, link|
  visit_in_email(link, address)
end

Then "{string} should see {string} in the email body" do |_address, text|
  expect(current_email.default_part_body.to_s).to include(text)
end

Then "{string} opens the email with subject {string}" do |address, subject|
  open_email(address, with_subject: subject)
end
