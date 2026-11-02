# frozen_string_literal: true

require 'rails_helper'
require 'open3'

# The nginx image runs files in /docker-entrypoint.d only when they are executable ("Ignoring" otherwise), so the
# script that reloads nginx after a certificate renewal must keep its executable mode in git.
describe "dockerized_app nginx entrypoint scripts" do # rubocop:disable RSpec/DescribeClass
  it "are executable in git" do
    skip "not a git checkout" unless Rails.root.join('.git').exist?

    begin
      stdout, status = Open3.capture2('git', '-C', Rails.root.to_s, 'ls-files', '-s', '--', 'dockerized_app/nginx/99-autoreload.sh')
    rescue Errno::ENOENT
      skip "git is not installed"
    end
    skip "git could not read the repository" unless status.success?

    expect(stdout.split.first).to eq '100755'
  end
end
