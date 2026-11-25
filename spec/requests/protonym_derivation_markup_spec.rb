# frozen_string_literal: true

require 'rails_helper'

describe "AntCat derivation on the protonym page" do
  let!(:protonym) do
    create :protonym, etymology_derivation:
      "Toponym: Formed from Mexico with the Latin adjectival suffix <i>-ensis</i>, 'of Mexico'."
  end

  it "renders the italics as markup, not as escaped tags (#1621)" do
    get protonym_path(protonym)

    expect(response).to have_http_status :ok
    expect(response.body).to include "Etymology (AntCat):"
    expect(response.body).to include "<i>-ensis</i>"
    expect(response.body).not_to include "&lt;i&gt;-ensis"
  end
end
