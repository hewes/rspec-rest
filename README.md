# Rspec::Rest

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'rspec-rest'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-rest

## Usage

### Configuration

- `RSpec.configuration.config_path`

  - default: 'config/'

#### Target Server Information

File path : `RSpec.configuration.config_path`/servers.yml

Each server configuration has following items:

- scheme: "http" or "https"
  - required: no
  - default: "http"
- address: server address (IP address or FQDN)
  - required: yes
- port: tcp port
  - required: no
  - default: 80
- base\_path: base path for request
  - required: no
- default: this server is default server
  - required: no
  - default: false
- ssl\_verify:
  - required: no
  - default: false

Example

~~~
server1:
  :scheme : http
  :address : localhost
  :port : 80
~~~

#### Authentication Information

File path : `RSpec.configuration.config_path`/authentications.yml

- mechanism: authentication mechanism
  - required: Yes
  - type: String
  - description:
    must be one of followings
    - basic: HTTP Basic Authentication
    - keystone\_v2: OpenStack keystone authentication with v2.0 API
    - keystone\_v3: OpenStack keystone authentication with v3 API

Other element depends on mechanism

- basic
  - user: username
    - required: Yes
    - type: String
  - password: password
    - required: Yes
    - type: String

- keystone\_v2
  - server: Keystone server identifier
    - required: Yes
    - type: String
    - NOTE: this value must be defined at `config/keystones.yml`
  - user: username
    - required: Yes
    - type: String
  - password: password
    - required: Yes
    - type: String
  - tenant: tenant name
    - required: Yes
    - type: String

- keystone\_v3
  - server: Keystone server identifier
    - required: Yes
    - type: String
    - NOTE: this value must be defined at `config/keystones.yml`
  - user: username
    - required: Yes
    - type: String
  - password: password
    - required: Yes
    - type: String
  - project: project name 
    - required: Yes
    - type: String
  - domain: domain name
    - required: Yes
    - type: String

#### Template files Information

- `RSpec.configuration.template_path`

  - default: 'template/'

#### RSpec behaviors

- `RSpec.configuration.use_synonym`

  - default: true

#### Keystone Server Information

File path : `RSpec.configuration.config_path`/keystones.yml

- scheme: "http" or "https"
  - required: no
  - type: String
  - default: "http"
- address: server address (IP address or FQDN)
  - required: yes
  - type: Integer or String
- port: tcp port
  - required: no
  - type: Integer or String
  - default: 80
- base\_path: base path for request
  - required: no
  - type: String
- ssl\_verify:
  - required: no
  - type: Boolean
  - default: false

## Contributing

1. Fork it ( https://github.com/[my-github-username]/rspec-rest/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

