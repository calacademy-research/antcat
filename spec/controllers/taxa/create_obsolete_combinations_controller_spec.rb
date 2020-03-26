# frozen_string_literal: true

require 'rails_helper'

describe Taxa::CreateObsoleteCombinationsController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(get(:show, params: { taxa_id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create, params: { taxa_id: 1 })).to have_http_status :forbidden }
    end
  end
end
