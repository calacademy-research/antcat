# see https://github.com/modeset/teaspoon/issues/443
module RaiseUnlessPrecompiledFixer
  def raise_unless_precompiled_asset path
    super unless path.split('.')[-2] == 'self'
  end
end
Sprockets::Rails::HelperAssetResolvers::Environment.send(:prepend, RaiseUnlessPrecompiledFixer)

Teaspoon.configure do |config|
  config.mount_at = "/teaspoon"
  config.root = nil
  config.asset_paths = ["spec/javascripts", "spec/javascripts/stylesheets"]
  config.fixture_paths = ["spec/javascripts/fixtures"]

  config.suite do |suite|
    suite.use_framework :jasmine, "2.3.4"
    suite.matcher = "{spec/javascripts,app/assets}/**/*_spec.{js,js.coffee,coffee}"
    suite.helper = "spec_helper"
    suite.boot_partial = "boot"
    suite.body_partial = "body"
    #suite.expand_assets = true
  end

  # Available drivers are [:phantomjs, :selenium, :capybara_webkit]
  #config.driver = :capybara_webkit
  config.driver = :phantomjs
  config.driver_options = nil

end
