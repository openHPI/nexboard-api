require 'spec_helper'

describe NexboardApi do
  let(:api_key) { 'RandomApiKey' }
  let(:user_id) { 1337 }
  let(:params)  { {api_key: api_key, user_id: user_id} }

  let(:api)     { NexboardApi.new **params }

  let(:default_base_url) { 'https://nexboard.nexenio.com/portal/api/public/' }
  let(:default_headers)  { {'Content-Type' => 'application/json'} }

  describe '#initialize' do
    subject { NexboardApi.new **params }

    it 'should be initialized with correct params' do
      expect(subject.api_key).to eq(api_key)
      expect(subject.user_id).to eq(user_id)
      expect(subject.base_url).to eq(default_base_url)
    end

    context 'with custom base_url' do
      let(:params) { super().merge(base_url: 'https://p3k.com') }

      it 'should be initialized with custom base_url' do
        expect(subject.base_url).to eq('https://p3k.com')
      end  
    end  

    context 'with template_project_id' do
      let(:params) { super().merge(template_project_id: 666) }

      it 'should be initialized with template_project_id' do
        expect(subject.template_project_id).to eq(666)
      end  
    end 
  end

  describe '#get_project_ids' do
    subject { api.get_project_ids }

    let!(:projects_stub) do
      stub_request(:get, "#{default_base_url}projects?token=#{api_key}&userId=#{user_id}").
         with(headers: default_headers).
         to_return(status: 200, body: "[{\"project_id\": 1}, {\"project_id\": 3000}]", headers: default_headers)
    end  

    it 'should request Nexboard API' do
      subject
      expect(projects_stub).to have_been_requested
    end 

    it 'should return a list of project ids' do
      expect(subject).to eq([1, 3000])
    end  
  end

  describe '#create_project' do
    let(:create_params) { {title: 'My project', description: 'My description'} }

    subject { api.create_project **create_params }

    let!(:create_project_stub) do
      stub_request(:post, "#{default_base_url}projects?token=#{api_key}").
         with(headers: default_headers, body: create_params.merge(user_id: user_id)).
         to_return(status: 200, body: "{}", headers: default_headers)
    end

    it 'should request Nexboard API' do
      subject
      expect(create_project_stub).to have_been_requested
    end 
  end

  describe '#get_boards_for_project' do
    let(:project_id) { 123 }

    subject { api.get_boards_for_project project_id: project_id }

    let(:board) do
      {
        boardId: 1,
        project_id: project_id,
        title: 'My board',
        description: 'My description'
      }
    end  

    let!(:boards_stub) do
      stub_request(:get, "#{default_base_url}projects/#{project_id}/boards?token=#{api_key}&userId=#{user_id}").
         with(headers: default_headers).
         to_return(status: 200, body: "[#{board.to_json}]", headers: default_headers)
    end

    it 'should request Nexboard API' do
      subject
      expect(boards_stub).to have_been_requested
    end

    it 'should return a list of board resources' do
      expect(subject.data.to_json).to eq([board].to_json)
    end 
  end

  describe '#create_board_for_project' do
    let(:create_params) { {project_id: 123, title: 'My title', description: 'My description'} }

    subject { api.create_board_for_project **create_params }

    let(:create_board_stub) do
      stub_request(:post, "#{default_base_url}boards?token=#{api_key}").
         with(headers: default_headers, body: create_params.merge(user_id: user_id)).
         to_return(status: 200, body: "{}", headers: default_headers)
    end

    before { create_board_stub; subject }

    it 'should request Nexboard API' do
      expect(create_board_stub).to have_been_requested
    end 

    context 'with template_id' do
      let(:create_params) { super().merge(template_id: 1234) }

      it 'should request Nexboard API' do
        expect(create_board_stub).to have_been_requested
      end 
    end  
  end
end
