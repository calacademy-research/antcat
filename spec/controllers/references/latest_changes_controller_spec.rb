# frozen_string_literal: true

require 'rails_helper'

describe References::LatestChangesController do
  describe "GET index", as: :visitor do
    specify { expect(get(:index)).to render_template :index }
  end
end
