# frozen_string_literal: true

def i_follow_the_first_linked_history_item
  first("a[href^='/history_items/']").click
end
