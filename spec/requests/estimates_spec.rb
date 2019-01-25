require 'rails_helper'

RSpec.describe 'Estimates API', type: :request do

  let!(:project) { create(:project) }
  let!(:estimates) { create_list(:estimate, 1, project_id: project.id) }
  let(:project_id) { project.id }
  let(:id) { estimates.first.id }


  describe 'GET /projects/:project_id/estimates' do
    before {
      project = Project.create(name: "Drake", description: "Super cool description")
      project.estimates.create(name: "Drake", optimistic: 10, realistic: 15, pessimistic: 25)
      project.estimates.create(name: "Drake", optimistic: 10, realistic: 15, pessimistic: 25)
      project.estimates.create(name: "Drake", optimistic: 10, realistic: 15, pessimistic: 25)

      get "/projects/#{project.id}/estimates"
    }

    context 'When estimates exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
      it 'returns all the estimates' do
        expect(json.size).to eq(3)
      end
    end

    context 'when project does not exist' do
      let(:project_id) { 0 }

      # it 'returns status code 404' do
      #   expect(response).to have_http_status(404)
      # end

      # it 'returns a not found message' do
      #   expect(response.body).to match(/Couldn't find Project/)
      # end
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
          expect(json["status"]).to eq(422)
      end

      it 'returns a validation failure message' do
        expect(json["message"][0]).to eq("Name can't be blank")
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
