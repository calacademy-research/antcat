# frozen_string_literal: true

module Taxt
  class Cleanup
    include Service

    attr_private_initialize :taxt

    def call
      return if taxt.nil?
      raise unless taxt.is_a?(String)

      taxt.
        gsub(/ +:/, ': ').       # Spaces before colons.
        gsub(%r{:(?!//)}, ': '). # Colons (not in "http://"); doubled spaces are squished below.
        gsub(/(; +;)+/, ';').    # Double semicolons separated by spacing.
        gsub(/(: +:)+/, ':').    # Double colons separated by spacing.
        gsub(/(::)+/, ':').      # Double colons.
        squish                   # Consecutive, and leading/trailing spaces.
    end
  end
end
