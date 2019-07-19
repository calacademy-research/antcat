require 'spec_helper'

describe References::LatestChangesController do
  describe "GET index" do
    specify { expect(get(:index)).to render_template :index }
  end
end
