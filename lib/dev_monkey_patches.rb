# Enabled in dev by default. Disable with `rails c NO_DEV_MONKEY_PATCHES=1`.
#
# All extensions to `Object` are Poor Man's namespaced under the prefix "dd" or
# "dev_dev". `Taxon` is extended with single-letter methods, but we do not have
# to fear name clashes, as no-one else in their right mind would do the same.
#
# "This is blasphemy! This is madness!"
# "Madness? THIS - IS... ANTCAT!! [kicks the Java developer into the deep well]
#
# Examples:
# `ddt("Atta").s.v.c` = valid Atta species count
#   => 17
#
# `ddpg ddrg.l` = puts AntCat catalog link of random species, with name, in green!
#   => http://antcat.org/catalog/429929?Leptothorax
#
# `ddfg.siblings.peach` = puts each siblings of the first genus
#   => Total: 31 of types Genus.
#      429012 (valid) genus Calyptites
#      429013 (valid) genus Condylodon ...
#
# `ddlt.ll.open` = launch web browser (xdg-open) and open last taxon on localhost

module DevMonkeyPatches
  def self.enable
    return if ENV["NO_DEV_MONKEY_PATCHES"]
    raise "#{name} cannot be enabled in production" if ::Rails.env.production?
    raise "use `#{name}.enable!` in test" if ::Rails.env.test?
    enable!
  end

  def self.enable!
    DevMonkeyPatches.enabled_notice

    DevMonkeyPatches::Object.patch!
    DevMonkeyPatches::Rails.patch!
    DevMonkeyPatches::AntCat.patch!
  end

  def self.enabled_notice
    $stdout.puts "Monkey patched `Object` and some Rails classes in `DevMonkeyPatches`.".yellow
    $stdout.puts "That's OK, ".green + "it's enabled in dev only by default. " +
      "See `lib/dev_monkey_patches.rb` for more info.".light_blue
  end
end
