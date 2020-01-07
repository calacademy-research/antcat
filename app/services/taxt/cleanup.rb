module Taxt
  class Cleanup
    include Service

    def initialize taxt
      @taxt = taxt
    end

    def call
      return if taxt.nil?
      raise unless taxt.is_a?(String)

      taxt.gsub(': :', ':').gsub(/ +/, ' ')
    end

    private

      attr_reader :taxt
  end
end
