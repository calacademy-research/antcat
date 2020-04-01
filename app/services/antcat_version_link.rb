# frozen_string_literal: true

class AntcatVersionLink
  include ActionView::Helpers::UrlHelper

  def call
    link_to latest_tag, url, title: commit_hash, class: 'external-link'
  end

  private

    def latest_tag
      `git describe HEAD --tags` # Something like "v2.4.2-46-g08aa818".
    end

    def commit_hash
      @_commit_hash ||= `git rev-parse HEAD`
    end

    def url
      "https://github.com/calacademy/antcat/commit/#{commit_hash}"
    end
end
