# frozen_string_literal: true

module Markdowns
  class MentionedUsers
    include Service

    def initialize content
      @content = content
    end

    def call
      User.where(id: user_ids)
    end

    private

      attr_reader :content

      def user_ids
        content.scan(Markdowns::ParseAntcatHooks::USER_TAG_REGEX).flatten.uniq
      end
  end
end
