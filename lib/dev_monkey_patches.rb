# frozen_string_literal: true

# Enabled in the development environment by default. Disable with `NO_DEV_MONKEY_PATCHES=1 rails c`.
# Enable in other environments with `DEV_MONKEY_PATCHES=1 rails c`.
#
# All extensions to `Object` are Poor Man's namespaced under the prefix "dd" or
# "dev_dev". `Taxon` is extended with single-letter methods, but we do not have
# to fear name clashes, as no-one else in their right mind would do the same.
#
# "This is blasphemy! This is madness!"
# "Madness? THIS - IS... ANTCAT!! [kicks the Java developer into the deep well]
#
# Examples:
# `ddt("Atta").species.count` = Atta species count
#   => 17
#
# `ddpg ddrg.l` = puts AntCat catalog link of random species, with name, in green!
#   => https://antcat.org/catalog/429929?Leptothorax
#
# `ddff.children.peach` = puts each child of the first genus
#   => Total: 31 of types Genus.
#      429012 (valid) genus Calyptites
#      429013 (valid) genus Condylodon ...
#
# `ddlt.ll.open` = launch web browser (xdg-open) and open last taxon on localhost

require_relative "dev_monkey_patches/ant_cat"
require_relative "dev_monkey_patches/array"
require_relative "dev_monkey_patches/object"
require_relative "dev_monkey_patches/rails"

module DevMonkeyPatches
  def self.enable
    return if ENV["NO_DEV_MONKEY_PATCHES"]

    $stdout.puts "`DevMonkeyPatches` was enabled in production!".red if ::Rails.env.production?
    $stdout.puts "`DevMonkeyPatches` was enabled in test!".red if ::Rails.env.test?

    enable!
  end

  def self.enable!
    DevMonkeyPatches.puts_enabled_notice

    DevMonkeyPatches::Object.patch!
    DevMonkeyPatches::Array.patch!
    DevMonkeyPatches::Rails.patch!
    DevMonkeyPatches::AntCat.patch!
  end

  def self.puts_enabled_notice
    $stdout.puts "Monkey patched `Object` and some Rails classes in `DevMonkeyPatches`.".yellow
    $stdout.puts "That's OK, ".green + "it's enabled in dev only by default. " +
      "See `lib/dev_monkey_patches.rb` for more info.".light_blue
  end
end
