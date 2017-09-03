# This is from rack/util.rb as of Aug 15, 2011
# It fixes warnings about comparing /.../n regexp
# to UTF-8 strings

# TODO see if we still need this.
module Rack
  module Utils
    def escape s
      URI.encode_www_form_component(s)
    end
  end
end
