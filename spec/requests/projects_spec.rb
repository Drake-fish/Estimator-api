require 'rails_helper'

RSpec.describe 'Projects API', type: :request do
  let!(:projects) {create_list(:project, 10)}
  let(:project_id) {projects.first.id}
  let!(:estimates) { create_list(:estimate, 20, project_id: projects.first.id) }
  let(:id) { estimates.first.id }


  describe 'GET /projects' do
    before {get '/projects'}

    it 'returns projects' do
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /projects/:id' do
    before { get "/projects/#{project_id}" }

    context 'when the record exists' do
      it 'returns the project' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(project_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:project_id) { 100 }

      it 'returns status code of 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Project with 'id'=100/)
      end
    end
  end

  describe 'GET /calculate/:id' do
    before { get "/calculate/#{id}"}

    context 'when the record exists' do
      it 'returns the estimate' do
        expect(json).not_to be_empty
      end
      it 'returns a status code of 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:id) { 200 }
      it 'returns status code of 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Estimate with 'id'=200/)
      end
    end
  end

  describe 'GET /calculate/:id/weighted' do
    before { get "/calculate/#{id}/weighted"}

    context 'when the record exists' do
      it 'returns the estimate' do
        expect(json).not_to be_empty
      end
      it 'returns a status code of 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:id) { 200 }
      it 'returns status code of 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Estimate with 'id'=200/)
      end
    end
  end

  describe 'GET /calculate/all/:id' do
    before { get "/calculate/all/#{id}"}

    context 'when the record exists' do
      it 'returns the averages added together' do
        expect(json).to_not be_empty
      end
      it 'returns a status code of 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:id) { 200 }
      it 'returns status code of 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Project with 'id'=200/)
      end
    end
  end

  describe 'GET /calculate/all/weighted/:id' do
    before { get "/calculate/all/weighted/#{id}"}

    context 'when the record exists' do
      it 'returns the averages added together' do
        expect(json).to_not be_empty
      end
      it 'returns a status code of 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:id) { 200 }
      it 'returns status code of 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Project with 'id'=200/)
      end
    end
  end




  describe 'POST /projects' do
    let(:valid_attributes) {{name: "Santa", description: "This is a project about chrstimas fool!"}}

    context 'When the request is valid' do
      before { post '/projects', params: valid_attributes }

      it 'creates a project' do
        expect(json['name']).to eq('Santa')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'When the request is invalid' do
      before { post '/projects', params: { name: 'Boo!' }}

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match(/Validation failed: Description can't be blank/)
      end
    end
  end

  describe 'PUT  /projects/:id' do
    let (:valid_attributes) {{ name: "Bob" }}

    context 'When the record exists' do
      before { put "/projects/#{project_id}", params: valid_attributes}

      it 'updates the record' do
        expect(response.body).to be_empty
      end

      it 'returns a status of 204' do
        expect(response).to have_http_status(204)
      end
    end
  end

  describe 'DELETE /projects/:id' do
    before { delete "/projects/#{project_id}" }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end
