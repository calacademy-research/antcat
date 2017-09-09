module AboutHelper
  def antcat_version
    latest_tag = `git describe HEAD --tags` # Something like "v2.4.2-46-g08aa818".
    commit_hash = `git rev-parse HEAD`
    url = "https://github.com/calacademy/antcat/commit/#{commit_hash}"

    link_to latest_tag, url, title: commit_hash
  end
end
