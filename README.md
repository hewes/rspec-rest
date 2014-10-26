# Rspec::Rest

`rspec-rest` is a library for testing WEB Server through Restful API with `rspec`.

*Feature*:

- define `rspec` matchers
  - `have_http_status` (like `rspec-rails`)
  - `have_http_header`
  - `include_json`
  - `have_uuid_format`
  - `have_guid_format`
  - `eql_json_value`
  - `contain`

- define helper methods for send http request to WEB server
  - send/receive http request/response
  - send http request with authentication (basic or Keystone(OpenStack)).

- management erb template files

*Simple Example*

```ruby
before do
  default_request do |req|
    req.server = "server1"
  end
end

it "responds 404 if URI is invalid" do
  get "/dir1/item1"
  expect(response).to have_http_status(:not_found)
end

it "responds 200 if authenticated as admin" do
  get "/dir1/item2" do |req|
    req.auth :admin
  end
  expect(response).to have_http_status(:ok)
  expect(response.body).to have_guid_format.in_json_path("root/resources/resource")
  expect(response.body).to include_json({resource: => {name: "name"}}.to_json).in_json_path("root/resources")
end
```

`response` returns instance of the last response (`Rspec::Rest::Http::Response`).

## Installation

Add this line to your application's Gemfile:

    gem 'rspec-rest'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-rest

## Usage

### Configuration

#### RSpec Configuraiton

```ruby
require "rspec/rest"

RSpec.configure do |c|
  c.config_path = "spec/target/config"
  c.template_path = "spec/target/template"
  c.use_synonym = true
end
```

|Config         |Required|Default   |Description                                              |
|---------------|--------|----------|---------------------------------------------------------|
|config\_path   |No      |config/   |path to directory where configuraiton files are stored   |
|template\_path |No      |template/ |path to directory where template files are stored        |

#### Target Server Information

File path : `RSpec.configuration.config_path`/servers.yml

Each server configuration has following items:

|Key        |Required|Default|Description                                              |
|-----------|--------|-------|---------------------------------------------------------|
|scheme     |No      |`http` |`http` or `https`                                        |
|host       |Yes     |-      |server address (IP address or FQDN)                      |
|port       |No      |`80`   |tcp port                                                 |
|base\_path |No      |-      |base path for all request                                |
|default    |No      |false  |use this server when server is not specified for request |
|ssl\_verify|No      |false  |when scheme is `https`, verify ssl or not                |

*Example*

```yaml
server1:
  scheme : http
  host : localhost
  port : 80
  default: true
  base_path: dir1/
server2:
  scheme : https
  host : localhost
  port : 443
  base_path: dir2/
  ssl_verify: true
```

#### Authentication Information

File path : `RSpec.configuration.config_path`/authentications.yml

|Key        |Required|Default|Description              |
|-----------|--------|-------|-------------------------|
|mechanism  |Yes     |-      |authentication mechanism |

`mechanism` must be one of followings

- basic: HTTP Basic Authentication
- keystone\_v2: OpenStack keystone authentication with v2.0 API
- keystone\_v3: OpenStack keystone authentication with v3 API

Other items depend on mechanism.

When mechanism is `basic`

|Key        |Required|Default|Description                                              |
|-----------|--------|-------|---------------------------------------------------------|
|user       |Yes     |-      |username                                                 |
|password   |Yes     |-      |password                                                 |

When mechanism is `keystone_v2`

|Key        |Required|Default|Description                                                           |
|-----------|--------|-------|----------------------------------------------------------------------|
|server     |Yes     |-      |Keystone server identifier (must be defined at `config/keystones.yml`)|
|user       |Yes     |-      |username                                                              |
|password   |Yes     |-      |password                                                              |
|tenant     |Yes     |-      |tenant name                                                           |

When mechanism is `keystone_v3`

|Key        |Required|Default|Description                                                           |
|-----------|--------|-------|----------------------------------------------------------------------|
|server     |Yes     |-      |Keystone server identifier (must be defined at `config/keystones.yml`)|
|user       |Yes     |-      |username                                                              |
|password   |Yes     |-      |password                                                              |
|project    |Yes     |-      |project name                                                          |
|domain     |Yes     |-      |domain name                                                           |

*Example*

```yaml
admin:
   mechanism: basic
   user: admin_user
   password: admin_password
```
#### Keystone Server Information

File path : `RSpec.configuration.config_path`/keystones.yml

format is same as `Target Server Information`

~~~
keystone1:
  scheme : http
  host : localhost
  port : 5000
~~~

example
## Contributing

1. Fork it ( https://github.com/[my-github-username]/rspec-rest/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

