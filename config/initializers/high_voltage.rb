# frozen_string_literal: true

# Removes the top-level prefix 'pages' from the URL
#   '/about' instead of '/pages/about'
#   '/help/tooltips' instead of '/pages/help/tooltips', etc, etc
# The views are till located in 'app/views/pages'. For some reason the extensions
# must include the html suffix '.html.haml", ie not just '.haml'.
HighVoltage.configure do |config|
  config.route_drawer = HighVoltage::RouteDrawers::Root
end
