require 'rails_helper'

describe Api::ApiController, as: :visitor do
  describe "limits" do
    controller do
      def index
        render json: with_limit(Reference.all)
      end
    end

    let!(:reference_1) { create :article_reference }
    let!(:reference_2) { create :article_reference }

    context 'without `params[:starts_at]`' do
      specify do
        get :index
        expect(json_response).to eq([reference_1, reference_2].as_json)
      end
    end

    context 'with `params[:starts_at]`' do
      specify do
        get :index, params: { starts_at: reference_2.id }
        expect(json_response).to eq([reference_2].as_json)
      end
    end
  end

  describe "rescuing `ActiveRecord::RecordNotFound`" do
    controller do
      def show
        raise ActiveRecord::RecordNotFound
      end
    end

    specify { expect(get(:show, params: { id: 0 })).to have_http_status :not_found }
  end
end
