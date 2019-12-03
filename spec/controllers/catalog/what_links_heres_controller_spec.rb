require 'rails_helper'

describe Catalog::WhatLinksHeresController do
  describe 'GET show' do
    let!(:taxon) { create :family }

    specify { expect(get(:show, params: { id: taxon.id })).to render_template :show }
  end
end
