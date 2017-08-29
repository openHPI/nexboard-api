# Nexboard API

`nexboard-api` is a wrapper for the Nexboard API (see http://nexboard-api.nexenio.com/) packaged as Ruby Gem.

The gem uses Restify (https://github.com/jgraichen/restify) for handling HTTP communication.

## Usage
Initialize the API with `API key` and `user_id` (both provided with your Nexboard API account). You can optionally add a `template_project_id`, which would be a Nexboard `project_id` where you store boards meant as templates for your application. If you run your own Nexboard server, you can add a custom `base_url`.

```ruby
require 'nexboard_api'

params = {
  api_key = 'my_secret_api_key',
  user_id = 1,
  template_project_id = 123,
  base_url = 'https://my-server.example.com/api/public/'
}

nexboard_api = NexboardApi.new **params

```

tbc.

## Contributing

- Fork it
- Create your feature branch (git checkout -b my-new-feature)
- Commit specs for your feature so that I do not break it later
- Commit your changes (git commit -am 'Add some feature')
- Push to the branch (git push origin my-new-feature)
- Create new Pull Request
