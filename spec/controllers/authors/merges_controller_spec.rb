# frozen_string_literal: true

require 'rails_helper'

describe Authors::MergesController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(get(:new, params: { author_id: 1 })).to have_http_status :forbidden }
      specify { expect(get(:show, params: { author_id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create, params: { author_id: 1 })).to have_http_status :forbidden }
    end
  end
end
