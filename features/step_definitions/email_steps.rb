# frozen_string_literal: true

def email_should_have_number_of_unread_emails address, amount
  expect(unread_emails_for(address).size).to eq parse_email_count(amount)
end

def email_should_see_in_the_email_body _address, text
  expect(current_email.default_part_body.to_s).to include(text)
end

def email_opens_the_email_with_subject address, subject
  open_email(address, with_subject: subject)
end
