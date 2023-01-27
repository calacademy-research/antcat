# frozen_string_literal: true

def there_is_an_activity_with_the_edit_summary edit_summary
  create :activity, Activity::EXECUTE_SCRIPT, edit_summary: edit_summary
end

def there_is_an_automated_activity_with_the_edit_summary edit_summary
  create :activity, Activity::EXECUTE_SCRIPT, :automated_edit, edit_summary: edit_summary
end

def i_should_see_number_of_items_in_the_activity_feed expected_count
  feed_items_count = all("table.activities > tbody tr").size
  expect(feed_items_count).to eq expected_count.to_i
end

def i_should_see_the_edit_summary content
  within "table.activities" do
    i_should_see content
  end
end

def there_is_a_journal_activity_by event, name
  journal = create :journal
  user = User.find_by(name: name) || create(:user, name: name)
  create :activity, event: event.to_sym, trackable: journal, user: user
end

def the_query_string_should_contain contain
  match = page.current_url[contain]
  expect(match).to be_truthy
end

def the_query_string_should_not_contain contain
  match = page.current_url[contain]
  expect(match).to eq nil
end
