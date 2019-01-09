require 'rails_helper'

RSpec.describe 'Projects API', type: :request do

  let!(:project) { create(:project) }
  let!(:estimates) { create_list(:estimate, 20, project_id: project.id) }
  let(:project_id) { project.id }
  let(:id) { estimates.first.id }

  describe 'GET /projects/:project_id/estimates' do
    before { get "/projects/#{project_id}/estimates" }

    context 'When estimates exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns all the estimates' do
        expect(json.size).to eq(20)
      end
    end

    context 'when project does not exist' do
      let(:project_id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Project/)
      end
    end
  end

  describe 'GET /projects/:project_id/estimates/:id' do

    before { get "/projects/#{project_id}/estimates/#{id}" }

    context 'when project estimate exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the item' do
        expect(json['id']).to eq(id)
      end
    end

    context 'when project estimate does not exist' do
      let(:id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Estimate with/)
      end
    end
  end

  describe 'POST /projects/:project_id/estimates' do
    let(:valid_attributes) {{ name: "Drake", optimistic: 3, realistic: 5, pessimistic: 10, note: "This is my estimate" }}

    context 'when request attributes are valid' do
      before { post "/projects/#{project_id}/estimates", params: valid_attributes }

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when there is an invalid request' do
      before { post "/projects/#{project_id}/estimates", params: {} }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a failure message' do
        expect(response.body).to match(/Validation failed: Name can't be blank, Optimistic can't be blank, Realistic can't be blank, Pessimistic can't be blank, Note can't be blank/)
      end
    end
  end

  describe 'PUT /projects/:project_id/estimates/:id' do
    let(:valid_attributes) {{ name: "BOB" }}

    before { put "/projects/#{project_id}/estimates/#{id}", params: valid_attributes }
    context 'when the estimate exists' do
      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end

      it 'updates the estimate' do
        updated_estimate = Estimate.find(id)
        expect(updated_estimate.name).to match(/BOB/)
      end
    end

    context 'when the estimate does not exist' do
      let(:id) { 0 }

      it 'returns status 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Estimate/)
      end
    end
  end

  describe 'DELETE /projects/:project_id/estimates/:id' do
    before { delete "/projects/#{project_id}/estimates/#{id}"}

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end
