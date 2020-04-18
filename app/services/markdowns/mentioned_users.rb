# frozen_string_literal: true

module Markdowns
  class MentionedUsers
    include Service

    attr_private_initialize :content

    def call
      User.where(id: user_ids)
    end

    private

      def user_ids
        content.scan(Markdowns::ParseAntcatTags::USER_TAG_REGEX).flatten.uniq
      end
  end
end
