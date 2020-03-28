# frozen_string_literal: true

require 'rails_helper'

describe References::WhatLinksHeresController do
  describe 'GET show', as: :visitor do
    let!(:reference) { create :any_reference }

    specify { expect(get(:show, params: { reference_id: reference.id })).to render_template :show }
  end
end
