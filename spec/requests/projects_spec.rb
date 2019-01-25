require 'rails_helper'

RSpec.describe 'Projects API', type: :request do
  let!(:projects) {create_list(:project, 10)}
  let(:project_id) {projects.last.id}
  let!(:id) { estimates.first.id }
  let!(:estimates) { create_list(:estimate, 1, project_id: project_id ) }
  let!(:estimate) { create :estimate, project_id: project_id }

  describe 'GET /projects' do
    before {get '/projects'}

    it 'returns projects' do
      expect(json).not_to be_empty
      expect(json.size).to eq(5)
    end
    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /projects/:id' do
    before(:each) do
      parent_project_id = projects.first.id
      task = create(:project, parent_id: parent_project_id)
      task2 = create(:project, parent_id: parent_project_id)
      task3 = create(:project, parent_id: parent_project_id)
      create(:estimate, project_id: task.id, optimistic: 3, realistic: 5, pessimistic: 7 )
      create(:estimate, project_id: task.id, optimistic: 2, realistic: 6, pessimistic: 8 )
      create(:estimate, project_id: task2.id, optimistic: 1, realistic: 3, pessimistic: 9 )
      create(:estimate, project_id: task2.id, optimistic: 2, realistic: 4, pessimistic: 10 )
      create(:estimate, project_id: task3.id, optimistic: 3, realistic: 5, pessimistic: 9 )
      create(:estimate, project_id: task3.id, optimistic: 5, realistic: 7, pessimistic: 10 )
      get "/projects/#{parent_project_id}"
    end

    context 'when the record exists' do
    #   it 'returns the project' do
    #     expect(json).not_to be_empty
    #     expect(json['project']['id']).to eq(project_id)
    #   end
    #
    #   it 'returns status code 200' do
    #     expect(response).to have_http_status(200)
    #   end

      it 'returns the correct parent weighted average' do
        expect(json["weighted_time"]).to eq(15.76)

      end
      it 'returns the correct parent average time' do
        expect(json["average_time"]).to eq(16.5)
      end

      it 'returns the correct parent standard deviation' do
        expect(json["standard_deviation"]).to eq(1.03)
      end

      it 'returns the correct child average time' do
        expect(json["children"][0]["average_time"]).to eq(5.17)
      end

      it 'returns the correct child weighted time' do
        expect(json["children"][0]["weighted_time"]).to eq(5.34)
      end

      it 'returns the correct child standard deviation' do
        expect(json["children"][0]["standard_deviation"]).to eq(0.84)
      end


    end

    context 'when the record does not exist' do
      let(:project_id) { 0 }

      # it 'returns status code of 404' do
      #   expect(response).to have_http_status(404)
      # end
      #
      # it 'returns a not found message' do
      #   expect(response.body).to match(/Couldn't find Project with 'id'=100/)
      # end
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
          expect(json["status"]).to eq(422)
      end

      it 'returns a validation failure message' do
        expect(json["message"][0]).to eq("Description can't be blank")
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
