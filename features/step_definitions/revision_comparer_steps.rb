# frozen_string_literal: true

When("I follow the first linked history item") do
  i_follow_the_first_linked_history_item
end
def i_follow_the_first_linked_history_item
  first("a[href^='/history_items/']").click
end
