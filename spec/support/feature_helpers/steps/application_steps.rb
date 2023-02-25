# frozen_string_literal: true

# General steps, specific to AntCat.
module FeatureHelpers
  module Steps
    def wait_for_taxt_editors_to_load
      if javascript_driver?
        find('body[data-test-taxt-editors-loaded="true"]')
      else
        $stdout.puts "skipping wait_for_taxt_editors_to_load because spec is not using javascript".red
      end
    end

    def these_settings yaml_string
      hsh = YAML.safe_load(yaml_string)
      Settings.merge!(hsh)
    end
  end
end
