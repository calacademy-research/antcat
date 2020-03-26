# frozen_string_literal: true

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
