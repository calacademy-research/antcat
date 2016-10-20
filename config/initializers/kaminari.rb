# I believe this is to circumvent a bug having to do with ActiveAdmin using
# kaminari, while will_paginate is used in the app.

Kaminari.configure do |config|
  config.page_method_name = :per_page_kaminari
end
