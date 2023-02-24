# frozen_string_literal: true

module FeatureHelpers
  module Steps
    # TODO: Check without visiting the activity page.
    # TODO: Check that the edit summary belongs to the activity.
    def there_should_be_an_activity content, edit_summary: nil
      visit activities_path

      within "table.activities" do
        expect(page.text).to match(content)

        if edit_summary
          expect(page).to have_content edit_summary
        end
      end
    end
  end
end
