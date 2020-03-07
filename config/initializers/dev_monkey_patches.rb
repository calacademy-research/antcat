# Disable with `NO_DEV_MONKEY_PATCHES=1 rails c`
DevMonkeyPatches.enable if Rails.env.development? || ENV['DEV_MONKEY_PATCHES']
