# frozen_string_literal: true

require 'rails_helper'

describe "Protonym locality in the catalog" do
  let!(:species) { create :species }

  before { species.protonym.update!(locality: 'Madagascar (<img src=x onerror=alert(1)>)') }

  it "is escaped on the catalog page" do
    get catalog_path(species)

    expect(response).to have_http_status :ok
    expect(response.body).to include "MADAGASCAR (&lt;img src=x onerror=alert(1)&gt;)."
    expect(response.body).not_to include "<img src=x onerror"
  end
end
