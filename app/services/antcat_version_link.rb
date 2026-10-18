# frozen_string_literal: true

# "Version 4.0.0 (abc1234)" on the About page, linked to the deployed commit on GitHub
# (AntCat::COMMIT, read once at boot in config/initializers/antcat_version.rb), or to the
# release notes when the commit is not known.
class AntCatVersionLink
  include ActionView::Helpers::UrlHelper

  GITHUB_COMMIT_BASE_URL = "#{Settings.github.repo_url}/commit/"
  GITHUB_RELEASES_URL = "#{Settings.github.repo_url}/releases"

  def call
    commit = AntCat::COMMIT
    if commit
      link_to "Version #{AntCat::VERSION} (#{commit[0, 7]})", "#{GITHUB_COMMIT_BASE_URL}#{commit}",
        title: commit, class: 'external-link'
    else
      link_to "Version #{AntCat::VERSION}", GITHUB_RELEASES_URL, class: 'external-link'
    end
  end
end
