# frozen_string_literal: true

class AntwebDataController < ApplicationController
  def index
    render file: "/data/antcat/shared/antcat.antweb.txt", layout: false, content_type: 'text/plain'
  end
end
