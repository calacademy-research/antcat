# frozen_string_literal: true

# TODO: Check without visiting the activity page.
# TODO: Check that the edit summary belongs to the activity.
def there_should_be_an_activity content, edit_summary: nil
  i_go_to 'the activity feed'

  within "table.activities" do
    expect(page.text).to match(content)

    if edit_summary
      expect(page).to have_content edit_summary
    end
  end
end

def there_is_a_journal_activity_by event, name
  journal = create :journal
  user = User.find_by(name: name) || create(:user, name: name)
  create :activity, event: event.to_sym, trackable: journal, user: user
end
