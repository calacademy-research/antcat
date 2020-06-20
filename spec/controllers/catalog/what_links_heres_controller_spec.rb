# frozen_string_literal: true

require 'rails_helper'

describe Catalog::WhatLinksHeresController do
  describe 'GET show', as: :visitor do
    let!(:taxon) { create :any_taxon }

    specify { expect(get(:show, params: { id: taxon.id })).to render_template :show }
  end
end
