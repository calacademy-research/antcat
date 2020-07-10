# frozen_string_literal: true

module Taxt
  class Cleanup
    include Service

    attr_private_initialize :taxt

    def call
      return if taxt.nil?
      raise unless taxt.is_a?(String)

      taxt.
        gsub(/ +:/, ': ').     # Spaces before colons.
        gsub(/:(?!= )/, ': '). # Colons not followed by a space.
        gsub(/(: +:)+/, ':').  # Double colons separated by spacing.
        gsub(/(::)+/, ':').    # Double colons.
        squish                 # Consecutive, and leading/trailing spaces.
    end
  end
end
