# frozen_string_literal: true

require 'spec_helper'

describe NexboardApi do
  subject(:api) { described_class.new(**params) }

  let(:api_key) { 'RandomApiKey' }
  let(:user_id) { 1337 }
  let(:params) { {api_key: api_key, user_id: user_id} }
  let(:default_base_url) { 'https://nexboard.nexenio.com/portal/api/v1/public/' }
  let(:default_headers) { {'Content-Type' => 'application/json'} }

  describe '#initialize' do
    it 'is initialized with correct params' do
      expect(api.api_key).to eq(api_key)
      expect(api.user_id).to eq(user_id)
      expect(api.base_url).to eq(default_base_url)
    end

    context 'with custom base_url' do
      let(:params) { super().merge(base_url: 'https://p3k.com') }

      it 'is initialized with custom base_url' do
        expect(api.base_url).to eq('https://p3k.com')
      end
    end

    context 'with template_project_id' do
      let(:params) { super().merge(template_project_id: 666) }

      it 'is initialized with template_project_id' do
        expect(api.template_project_id).to eq(666)
      end
    end
  end

  describe '#project_ids' do
    subject(:project_ids) { api.project_ids }

    let!(:projects_stub) do
      stub_request(:get, "#{default_base_url}projects?token=#{api_key}&userId=#{user_id}")
        .with(headers: default_headers)
        .to_return(status: 200, body: '[{"id": 1}, {"id": 3000}]', headers: default_headers)
    end

    it 'requests Nexboard API' do
      project_ids
      expect(projects_stub).to have_been_requested
    end

    it 'returns a list of project ids' do
      expect(project_ids).to eq([1, 3000])
    end
  end

  describe '#create_project' do
    subject(:create_project) { api.create_project(**create_params) }

    let(:create_params) { {title: 'My project', description: 'My description'} }

    let(:create_body) do
      {
        userId: user_id,
        title: 'My project',
        description: 'My description',
      }
    end

    let!(:create_project_stub) do
      stub_request(:post, "#{default_base_url}projects?token=#{api_key}")
        .with(
          headers: default_headers,
          body: create_body,
        )
        .to_return(status: 200, body: '{}', headers: default_headers)
    end

    it 'requests Nexboard API' do
      create_project
      expect(create_project_stub).to have_been_requested
    end

    context 'without description' do
      let(:create_params) { {title: 'My project'} }

      let(:create_body) do
        {
          userId: user_id,
          title: 'My project',
        }
      end

      it 'requests Nexboard API' do
        create_project
        expect(create_project_stub).to have_been_requested
      end
    end
  end

  describe '#boards_for_project' do
    subject(:boards) { api.boards_for_project project_id: project_id }

    let(:project_id) { 123 }

    let(:board) do
      {
        id: 1,
        projectId: project_id,
        title: 'My board',
        description: 'My description',
      }
    end

    let!(:boards_stub) do
      stub_request(:get, "#{default_base_url}projects/#{project_id}/boards?token=#{api_key}&userId=#{user_id}")
        .with(headers: default_headers)
        .to_return(status: 200, body: "[#{board.to_json}]", headers: default_headers)
    end

    it 'requests Nexboard API' do
      boards
      expect(boards_stub).to have_been_requested
    end

    it 'returns a list of board resources' do
      expect(boards.data.to_json).to eq([board].to_json)
    end

    context 'without description' do
      let(:board) do
        {
          id: 1,
          projectId: project_id,
          title: 'My board',
        }
      end

      it 'requests Nexboard API' do
        boards
        expect(boards_stub).to have_been_requested
      end
    end
  end

  describe '#create_board' do
    subject(:create_board) { api.create_board(**create_params) }

    let(:create_params) do
      {
        project_id: 123,
        title: 'My title',
        description: 'My description',
      }
    end

    let(:create_body) do
      {
        projectId: 123,
        title: 'My title',
        description: 'My description',
        userId: user_id,
      }
    end

    let(:create_board_stub) do
      stub_request(:post, "#{default_base_url}boards?token=#{api_key}")
        .with(headers: default_headers, body: create_body)
        .to_return(status: 200, body: '{}', headers: default_headers)
    end

    before { create_board_stub; create_board }

    it 'requests Nexboard API' do
      expect(create_board_stub).to have_been_requested
    end

    context 'with template_id' do
      let(:create_params) do
        {
          project_id: 123,
          title: 'My title',
          description: 'My description',
          template_id: 1234,
        }
      end

      let(:create_body) do
        {
          projectId: 123,
          title: 'My title',
          description: 'My description',
          userId: user_id,
          template_id: 1234,
        }
      end

      it 'requests Nexboard API' do
        expect(create_board_stub).to have_been_requested
      end
    end
  end
end
