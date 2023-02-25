# frozen_string_literal: true

module FeatureHelpers
  module Steps
    def there_should_be_an_activity did_something, edit_summary: nil
      activity = Activity.last

      # HACK: Name ignored (it's fine) because it's easier to read expectations that are full sentences.
      # TODO: Probably make it more obvious that it's not checked.
      did_something = did_something.delete_prefix('Archibald ')
      normalized_did_something = ActionController::Base.helpers.strip_tags(activity.decorate.did_something).squish

      expect(normalized_did_something).to match did_something
      expect(activity.edit_summary).to eq edit_summary
    end
  end
end
