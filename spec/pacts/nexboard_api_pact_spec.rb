require 'pact_helper'

describe NexboardApi, :pact => true do
  let(:api_key) { 'RandomApiKey' }
  let(:user_id) { '1337' }
  let(:base_url) { 'http://localhost:1234/' }
  let(:params)  { {api_key: api_key, user_id: user_id, base_url: base_url} }
  let(:encoded_credentials) { URI::encode("token=#{api_key}&userId=#{user_id}") }
  let(:encoded_token) { URI::encode("token=#{api_key}") }
  let(:client) { NexboardApi.new **params }


  describe "get_project_ids" do
    let(:response) { [{project_id: '1'}, {project_id: '2'}] }

    before do
      nexboard.given("user has valid credentials and some projects exist").
          upon_receiving("a request to get all projects").
          with(method: :get, path: '/projects', query: encoded_credentials).
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

  describe "create_project" do
    let(:title) { 'A new project' }
    let(:description) { 'This is a new project' }
    let(:project_id) { '1' }
    let(:response) { {project_id: project_id, title: title} }
    let(:project_data) { {title: title, description: description} }
    let(:post_body) { {title: title, description: description, user_id: user_id} }

    before do
      nexboard.given("user has valid credentials").
          upon_receiving("a request to create a project").
          with(method: :post, path: '/projects', query: encoded_token, body: post_body).
          will_respond_with(
              status: 200,
              headers: {'Content-Type' => 'application/json'},
              body: response)
    end

    it "returns a new project" do
      project = client.create_project(project_data)
      expect(project.project_id).to eq(project_id)
    end

  end

  describe "get_boards_for_project" do
    let(:title) { 'A board' }
    let(:project_id) { '1' }
    let(:board_id) { '101' }
    let(:response) { [{boardId: board_id, title: title}] }

    before do
      nexboard.given("user has valid credentials and an existing project with boards").
          upon_receiving("a request to get boards of a project").
          with(method: :get, path: "/projects/#{project_id}/boards", query: encoded_credentials).
          will_respond_with(
              status: 200,
              headers: {'Content-Type' => 'application/json'},
              body: response)
    end

    it "returns a new project" do
      boards = client.get_boards_for_project( {project_id: project_id} )
      expect(boards.first.boardId).to eq(board_id)
    end

  end

  describe "create_board_for_project" do
    let(:title) { 'A new project' }
    let(:description) { 'This is a new project' }
    let(:project_id) { '1' }
    let(:board_id) { '101' }
    let(:response) { {board_id: board_id, project_id: project_id, title: title} }
    let(:board_data) { {title: title, description: description, project_id: project_id} }
    let(:post_body) { {title: title, description: description, project_id: project_id, user_id: user_id} }

    before do
      nexboard.given("user has valid credentials and an existing project").
          upon_receiving("a request to create a project").
          with(method: :post, path: '/boards', query: encoded_token, body: post_body).
          will_respond_with(
              status: 200,
              headers: {'Content-Type' => 'application/json'},
              body: response)
    end

    it "returns a new project" do
      board = client.create_board_for_project(board_data)
      expect(board.board_id).to eq(board_id)
    end

  end

end