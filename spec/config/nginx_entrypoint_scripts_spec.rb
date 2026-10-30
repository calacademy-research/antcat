# frozen_string_literal: true

require 'rails_helper'

# The nginx image runs files in /docker-entrypoint.d only when they are executable ("Ignoring" otherwise), so the
# script that reloads nginx after a certificate renewal must keep its executable mode in git.
describe "dockerized_app nginx entrypoint scripts" do
  it "are executable in git" do
    path = 'dockerized_app/nginx/99-autoreload.sh'
    mode = `git -C #{Rails.root} ls-files -s #{path}`.split.first
    expect(mode).to eq '100755'
  end
end
