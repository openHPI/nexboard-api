require 'pact_helper'

describe NexboardApi, :pact => true do
  let(:api_key) { 'RandomApiKey' }
  let(:user_id) { '1337' }
  let(:base_url) { 'http://localhost:1234/' }
  let(:params)  { {api_key: api_key, user_id: user_id, base_url: base_url} }
  client = nil

  before do
    # Configure your client to point to the stub service on localhost using the port you have specified
    client = NexboardApi.new **params
  end

  describe "get_project_ids" do
    let(:response) { [{project_id: '1'}, {project_id: '2'}] }

    before do
      nexboard.given("some projects exist").
          upon_receiving("a request for all project ids").
          with(method: :get, path: '/projects', query: URI::encode('token=' + api_key + '&userId=' + user_id)).
          will_respond_with(
              status: 200,
              headers: {'Content-Type' => 'application/json'},
              body: response)
    end

    it "returns the project ids" do
      project_ids = client.get_project_ids
      expect(project_ids).to eq(['1', '2'])
    end

  end

end