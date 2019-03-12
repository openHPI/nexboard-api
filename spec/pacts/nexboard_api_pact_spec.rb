require 'pact_helper'

describe NexboardApi, :pact => true do
  let(:api_key) { 'OpenHPIAPIKey' }
  let(:user_id) { '__user_id__' }
  let(:project1_id) { '__project_1_id__' }
  let(:project2_id) { '__project_2_id__' }
  let(:base_url) { 'http://localhost:1234/' }
  let(:params)  { {api_key: api_key, user_id: user_id, base_url: base_url} }
  let(:encoded_credentials) { URI::encode("token=#{api_key}&userId=#{user_id}") }
  let(:encoded_token) { URI::encode("token=#{api_key}") }
  let(:client) { NexboardApi.new **params }


  describe "get_project_ids" do
    let(:response) { [{title: 'Project1'}, {title: 'Project2'}] }

    before do
      nexboard.given("user has valid credentials and some projects exist").
          upon_receiving("a request to get all projects").
          with(method: :get, path: '/projects', query: encoded_credentials).
          will_respond_with(
              status: 200,
              headers: {'Content-Type' => 'application/json; charset=utf-8'},
              body: response)
    end

    it "returns the project ids" do
      project_ids = client.get_project_ids
      expect(project_ids).to eq([project1_id, project2_id])
    end

  end

  describe "create_project" do
    let(:title) { 'A new project' }
    let(:description) { 'This is a new project' }
    let(:response) { {description: description, title: title} }
    let(:project_data) { {title: title, description: description} }
    let(:post_body) { {title: title, description: description, user_id: user_id} }

    before do
      nexboard.given("user has valid credentials").
          upon_receiving("a request to create a project").
          with(method: :post, path: '/projects', query: encoded_token, body: post_body).
          will_respond_with(
              status: 200,
              headers: {'Content-Type' => 'application/json; charset=utf-8'},
              body: response)
    end

    it "returns a new project" do
      project = client.create_project(project_data)
      expect(project.title).to eq(title)
    end

  end

  describe "get_boards_for_project" do
    let(:title) { 'A board' }
    let(:description) { 'This is a great Board'}
    let(:response) { [{description: description, title: title}] }

    before do
      nexboard.given("user has valid credentials and an existing project with boards").
          upon_receiving("a request to get boards of a project").
          with(method: :get, path: "/projects/#{project1_id}/boards", query: encoded_credentials).
          will_respond_with(
              status: 200,
              headers: {'Content-Type' => 'application/json; charset=utf-8'},
              body: response)
    end

    it "returns a new project" do
      boards = client.get_boards_for_project( {project_id: project1_id} )
      expect(boards.first.title).to eq(title)
    end

  end

  describe "create_board_for_project" do
    let(:title) { 'New Board' }
    let(:description) { 'This is a new Board' }
    let(:response) { {description: description, title: title} }
    let(:board_data) { {title: title, description: description, project_id: project1_id} }
    let(:post_body) { {title: title, description: description, project_id: project1_id, user_id: user_id} }

    before do
      nexboard.given("user has valid credentials and an existing project").
          upon_receiving("a request to create a board").
          with(method: :post, path: '/boards', query: encoded_token, body: post_body).
          will_respond_with(
              status: 200,
              headers: {'Content-Type' => 'application/json; charset=utf-8'},
              body: response)
    end

    it "returns a new Board" do
      board = client.create_board_for_project(board_data)
      expect(board.title).to eq(title)
    end

  end

end