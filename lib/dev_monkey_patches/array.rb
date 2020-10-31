# frozen_string_literal: true

module DevMonkeyPatches
  module Array
    def self.patch!
      ::Array.include self
    end

    def dev_dev_localhost_link_open
      each do |object|
        object.ll.open
      end
      nil # Suppress echo in console.
    end
    alias_method :llo, :dev_dev_localhost_link_open
  end
end
