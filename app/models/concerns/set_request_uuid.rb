# frozen_string_literal: true

# Stamps a new row with the id of the request that made it, so the versions and the activity of one save can be
# found together.
module SetRequestUuid
  extend ActiveSupport::Concern

  included do
    before_create :set_request_uuid
  end

  private

    def set_request_uuid
      self.request_uuid = RequestStore.read(:current_request_uuid)
    end
end
