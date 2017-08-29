class NexboardApi
  DEFAULT_BASE_URL = 'https://nexboard.nexenio.com/portal/api/public/'.freeze

  attr_reader :api_key, :user_id, :template_project_id, :base_url

  def initialize(api_key:, user_id:, template_project_id: nil, base_url: nil)
    @api_key             = api_key
    @user_id             = user_id
    @template_project_id = template_project_id unless template_project_id.nil?
    @base_url            = if base_url.nil?
                             DEFAULT_BASE_URL
                           else
                             base_url
                           end    
  end
    
  def get_project_ids
    projects = Restify.new(@base_url + 'projects')
                   .get(userId: @user_id, token: @api_key)
                   .value!

    projects.data.map{|project| project['project_id']}
  end

  def create_project(title:, description:)
    data = {
        title: title,
        description: description,
        user_id: @user_id
    }

    Restify.new(@base_url + 'projects')
        .post(data, token: @api_key)
        .value!
  end

  def get_boards_for_project(project_id:)
    Restify.new(@base_url + 'projects/{project_id}/boards')
        .get(project_id: project_id, token: @api_key, userId: @user_id)
        .value!
  end

  def get_template_boards
    return [] if @template_project_id.nil?
    template_boards = get_boards_for_project(project_id: @template_project_id)
    template_boards.data.map{ |board| {board_id: board['boardId'], title: board['title'] } }
  end

  def create_board_for_project(project_id:, title:, description:, template_id: nil)
    data = {
        project_id: project_id,
        title: title,
        description: description,
        user_id: @user_id
    }
    data.merge!(template_id: template_id) unless template_id.nil?

    Restify.new(@base_url + 'boards')
        .post(data, token: @api_key)
        .value!
  end
end