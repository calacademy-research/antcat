# frozen_string_literal: true

# AntCat's release number, shown in the site footer and linked to the GitHub
# release notes. Set it in the VERSION file when a release is cut.
#
# AntCat::COMMIT is the full git commit hash the app was booted from, shown
# (shortened) next to the version and linked to the commit on GitHub. Read once
# at boot: a deploy is `git pull` plus a container restart. The checkout,
# including .git, is mounted into the container at /app, so the hash is read
# straight from .git (no git command, which would refuse a checkout owned by
# another user). A REVISION file at the app root wins if present. nil when it
# cannot be determined; the footer then shows only the version.
module AntCat
  VERSION = begin
    Rails.root.join("VERSION").read.strip
  rescue Errno::ENOENT
    "unknown"
  end

  module GitCommit
    HASH = /\A\h{40}\z/

    module_function

    def read root
      root = Pathname.new(root)
      from_file(root.join("REVISION")) || from_git_dir(git_dir(root))
    rescue StandardError
      nil
    end

    def from_file path
      return unless path.file?
      sha = path.read.strip.downcase
      sha if sha.match?(HASH)
    end

    # .git is a directory, or (worktrees, submodules) a file "gitdir: <path>".
    def git_dir root
      dot_git = root.join(".git")
      return dot_git if dot_git.directory?
      return unless dot_git.file?
      target = dot_git.read[/\Agitdir: (.+)$/, 1]
      root.join(target.strip) if target
    end

    def from_git_dir dir
      return unless dir&.directory?
      head = dir.join("HEAD").read.strip
      return head.downcase if head.match?(HASH) # detached HEAD
      ref = head[/\Aref: (.+)\z/, 1]
      return unless ref
      # A worktree keeps its branch refs in the main repository's git dir.
      common = dir.join("commondir").file? ? dir.join(dir.join("commondir").read.strip) : dir
      [dir, common].uniq.each do |d|
        sha = from_file(d.join(ref))
        return sha if sha
      end
      packed = common.join("packed-refs")
      return unless packed.file?
      packed.each_line do |line|
        sha, name = line.split
        return sha.downcase if name == ref && sha.match?(HASH)
      end
      nil
    end
  end

  COMMIT = GitCommit.read(Rails.root)
end
