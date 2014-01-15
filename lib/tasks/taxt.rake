# coding: UTF-8
namespace :taxt do
  desc "Go through all taxt and replace {nam}s with {tax}s where possible"
  task replace_name_tags: :environment do
    Taxt.cleanup true
  end
end
