# frozen_string_literal: true

class AntCatVersionLink
  include ActionView::Helpers::UrlHelper

  GITHUB_COMMIT_BASE_URL = "#{Settings.github.repo_url}/commit/"

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
      "#{GITHUB_COMMIT_BASE_URL}#{commit_hash}"
    end
end
