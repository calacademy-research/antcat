# frozen_string_literal: true

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
