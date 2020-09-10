# frozen_string_literal: true

require 'rails_helper'

describe EditorsPanels::RestartAndReindexSolrsController do
  describe "forbidden actions" do
    context "when signed in as an editor", as: :editor do
      specify { expect(post(:create)).to have_http_status :forbidden }
    end
  end

  describe "POST create", as: :superadmin do
    it "calls `RestartAndReindexSolr`" do
      service = instance_double(RestartAndReindexSolr)
      allow(RestartAndReindexSolr).to receive(:new).and_return(service)
      allow(service).to receive(:call)

      post(:create)

      expect(service).to have_received(:call)
    end
  end
end
