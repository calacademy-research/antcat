# frozen_string_literal: true

module MetaTagsHelper
  def noindex
    content_for :meta_tags do
      tag :meta, name: "robots", content: "noindex"
    end
  end
end
