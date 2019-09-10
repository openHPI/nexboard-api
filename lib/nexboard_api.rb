# frozen_string_literal: true

require 'restify'

class NexboardApi
  DEFAULT_BASE_URL = 'https://nexboard.nexenio.com/portal/api/v1/public/'

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

  def project_ids
    projects = Restify.new(URI.join(base_url, 'projects'))
      .get(userId: user_id, token: api_key)
      .value!
    projects.data.map(&:id)
  end

  def create_project(title:, description: nil)
    data = {
      title: title,
      userId: user_id,
    }
    data[:description] = description if description

    Restify.new(URI.join(base_url, 'projects'))
      .post(data, token: api_key)
      .value!
  end

  def boards_for_project(project_id:)
    Restify.new(URI.join(base_url, "projects/#{project_id}/boards"))
      .get(token: api_key, userId: user_id)
      .value!
  end

  def template_boards
    return [] if template_project_id.nil?

    template_boards = boards_for_project(project_id: template_project_id)
    template_boards
      .data
      .map {|board| {board_id: board['id'], title: board['title']} }
  end

  def create_board(project_id:, title:, description: nil, template_id: nil)
    data = {
      projectId: project_id,
      userId: user_id,
      title: title,
    }
    data[:description] = description if description
    data[:template_id] = template_id unless template_id.nil?

    Restify.new(URI.join(base_url, 'boards'))
      .post(data, token: api_key)
      .value!
  end

  def upload_image_to_board(board_id:, uploaded_io:)
    uri = URI.join(
      base_url,
      "boards/images/#{board_id}",
      "?token=#{api_key}",
    )

    multipart_request uri, uploaded_io
  end

  private

  BOUNDARY = 'NexboardApiP3K'

  def multipart_request(uri, uploaded_io)
    uploaded_io.rewind

    http = Net::HTTP.new uri.host, uri.port
    request = Net::HTTP::Post.new uri.request_uri
    request.body = post_body
    request['Content-Type'] = "multipart/form-data, boundary=#{BOUNDARY}"

    response = http.request(request)
    response.is_a? Net::HTTPSuccess
  end

  def post_body(uploaded_io)
    post_body = []
    post_body << "--#{BOUNDARY}\r\n"
    post_body << 'Content-Disposition: form-data; name="datafile"; '
    post_body << "filename=\"#{to_ascii(uploaded_io.original_filename)}\"\r\n"
    post_body << "Content-Type: text/plain\r\n"
    post_body << "\r\n"
    post_body << uploaded_io.tempfile.read
    post_body << "\r\n--#{BOUNDARY}--\r\n"
    post_body.join
  end

  def to_ascii(str)
    str.encode('ascii', invalid: :replace, undef: :replace, replace: '?')
  end
end
