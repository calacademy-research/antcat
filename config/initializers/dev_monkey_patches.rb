# frozen_string_literal: true

# Disable with `NO_DEV_MONKEY_PATCHES=1 rails c`
if Rails.env.development? || ENV['DEV_MONKEY_PATCHES']
  require Rails.root.join('lib/dev_monkey_patches')
  DevMonkeyPatches.enable
end
