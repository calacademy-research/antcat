# frozen_string_literal: true

module FeatureHelpers
  module Steps
    def i_write_a_new_comment body
      first("#comment_body").set body
    end
  end
end
