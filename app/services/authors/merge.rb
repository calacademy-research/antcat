# frozen_string_literal: true

module Authors
  class Merge
    include Service

    def initialize target_author, author_to_merge
      @target_author = target_author
      @author_to_merge = author_to_merge
    end

    def call
      Author.transaction do
        author_to_merge.names.each do |name|
          name.update!(author: target_author)
        end
        author_to_merge.reload.destroy! # Reload first to avoid deleting transferred `AuthorName`s.
      end
    end

    private

      attr_reader :target_author, :author_to_merge
  end
end
