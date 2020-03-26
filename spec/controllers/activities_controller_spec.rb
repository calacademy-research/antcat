# frozen_string_literal: true

require 'rails_helper'

describe ActivitiesController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as an editor", as: :editor do
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end
end
