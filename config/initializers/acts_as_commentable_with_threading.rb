module Acts
  module CommentableWithThreading
    module LocalInstanceMethods
      def comments_count
        comment_threads.count
      end

      def commenters
        comment_threads.map(&:user).uniq
      end
    end
  end
end
