# frozen_string_literal: true

module Markdowns
  class MentionedUsers
    include Service

    # Mentions send emails, so only the first few distinct users mentioned are notified.
    MAX_MENTIONED_USERS = 10

    attr_private_initialize :content

    def call
      User.active.where(id: user_ids)
    end

    private

      def user_ids
        content.scan(Markdowns::ParseAntCatTags::USER_TAG_REGEX).flatten.uniq.first(MAX_MENTIONED_USERS)
      end
  end
end
