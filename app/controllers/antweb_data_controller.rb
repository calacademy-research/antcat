class AntwebDataController < ApplicationController

  def index
    render file: "/Users/joe/antcat/boo.txt", layout: false, content_type: 'text/plain'
    # render file: "/data/antcat/shared/antcat.antweb.txt", layout: false, content_type: 'text/plain'

  end
end


