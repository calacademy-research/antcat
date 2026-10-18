# frozen_string_literal: true

require 'rails_helper'

describe "AntCat::VERSION" do
  it "is the release number from the VERSION file" do
    expect(AntCat::VERSION).to eq Rails.root.join("VERSION").read.strip
    expect(AntCat::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end

describe AntCat::GitCommit do
  let(:sha) { "5166c5a2#{'0' * 32}" }
  let(:other_sha) { "abcdef12#{'1' * 32}" }

  let(:root) { Pathname.new(Dir.mktmpdir) }

  after { FileUtils.remove_entry(root) }

  def write path, content
    path = root.join(path)
    FileUtils.mkdir_p(path.dirname)
    path.write(content)
  end

  it "is nil without .git or REVISION" do
    expect(described_class.read(root)).to eq nil
  end

  it "reads the branch ref that HEAD points to" do
    write ".git/HEAD", "ref: refs/heads/master\n"
    write ".git/refs/heads/master", "#{sha}\n"
    expect(described_class.read(root)).to eq sha
  end

  it "reads a detached HEAD" do
    write ".git/HEAD", "#{sha}\n"
    expect(described_class.read(root)).to eq sha
  end

  it "falls back to packed-refs" do
    write ".git/HEAD", "ref: refs/heads/master\n"
    write ".git/packed-refs", "# pack-refs with: peeled fully-peeled sorted\n#{other_sha} refs/heads/other\n#{sha} refs/heads/master\n"
    expect(described_class.read(root)).to eq sha
  end

  it "follows a worktree's .git file to the main repository's refs" do
    write "main/.git/worktrees/wt/HEAD", "ref: refs/heads/feature\n"
    write "main/.git/worktrees/wt/commondir", "../..\n"
    write "main/.git/refs/heads/feature", "#{sha}\n"
    write "wt/.git", "gitdir: ../main/.git/worktrees/wt\n"
    expect(described_class.read(root.join("wt"))).to eq sha
  end

  it "prefers a REVISION file" do
    write ".git/HEAD", "#{other_sha}\n"
    write "REVISION", "#{sha}\n"
    expect(described_class.read(root)).to eq sha
  end

  it "ignores anything that is not a full hash" do
    write ".git/HEAD", "ref: refs/heads/master\n"
    write ".git/refs/heads/master", "garbage\n"
    write "REVISION", "not-a-hash\n"
    expect(described_class.read(root)).to eq nil
  end
end
