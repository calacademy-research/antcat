# frozen_string_literal: true

def a_journal_exists_with_a_name_of name
  create :journal, name: name
end
