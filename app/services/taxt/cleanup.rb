# frozen_string_literal: true

module Taxt
  class Cleanup
    include Service

    attr_private_initialize :taxt

    def call
      return if taxt.nil?
      raise unless taxt.is_a?(String)

      taxt.
        gsub(/ +:/, ': ').     # Spacees before colons.
        gsub(/:(?!= )/, ': '). # Colons not followed by a space.
        gsub(/(: +:)+/, ':').  # Double colons separated by spacing.
        gsub(/(::)+/, ':').    # Double colons.
        gsub(/ +/, ' ').       # Consecutive spaces.
        strip
    end
  end
end
