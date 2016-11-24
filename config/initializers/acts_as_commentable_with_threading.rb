module Acts
  module CommentableWithThreading
    module LocalInstanceMethods
      def comments_count
        comment_threads.count
      end
    end
  end
end
