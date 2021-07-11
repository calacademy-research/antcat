# frozen_string_literal: true

require 'rails_helper'

describe 'routes', type: :routing do
  describe '/wiki' do
    specify do
      expect(get("/wiki/1")).to route_to("wiki_pages#show", id: "1")
    end
  end
end
