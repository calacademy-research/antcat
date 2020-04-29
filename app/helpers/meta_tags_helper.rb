# frozen_string_literal: true

module MetaTagsHelper
  def noindex_meta_tag
    content_for :meta_tags do
      tag :meta, name: "robots", content: "noindex"
    end
  end

  def description_meta_tag
    content = content_for(:description_meta_tag) || "An online catalog of the ants of the world."
    tag :meta, name: "description", content: content
  end
end
