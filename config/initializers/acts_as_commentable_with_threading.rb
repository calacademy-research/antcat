module Acts
  module CommentableWithThreading
    module LocalInstanceMethods
      def comments_count
        comment_threads.count
      end

      def commenters
        comment_threads.map(&:user).uniq
      end

      def any_comments?
        comment_threads.any?
      end
    end
  end
end
