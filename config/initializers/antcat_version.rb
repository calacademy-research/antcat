# frozen_string_literal: true

# AntCat's release number, shown in the site footer and linked to the GitHub
# release notes. Set it in the VERSION file when a release is cut.
module AntCat
  VERSION = begin
    Rails.root.join("VERSION").read.strip
  rescue Errno::ENOENT
    "unknown"
  end
end
