# frozen_string_literal: true

Given("there is a history item {string}") do |taxt|
  create :taxon_history_item, taxt: taxt
end
