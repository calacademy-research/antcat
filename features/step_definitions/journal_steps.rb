# frozen_string_literal: true

Given("a journal exists with a name of {string}") do |name|
  a_journal_exists_with_a_name_of name
end
def a_journal_exists_with_a_name_of name
  create :journal, name: name
end
