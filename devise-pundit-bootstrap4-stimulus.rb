# because bootstrap
gem 'jquery-rails'

#
gem 'webpacker', '~> 3.5'

gem 'responders'

# Slim is a template language whose goal is reduce the syntax to the essential parts without becoming cryptic.
gem 'slim-rails'

# A library for generating fake data such as names, addresses, and phone numbers.
gem 'faker'

# A library for setting up Ruby objects as test data.
gem 'factory_bot_rails', '~> 4.0'

gem 'sidekiq'

# active record and helpers
gem 'acts_as_list'

# authentication
gem 'devise'

# authorization
gem 'pundit'

# external APIs
gem 'httparty'



# german stuff
gem 'rails-i18n', '~> 5.1'
gem 'i18n-date'

# fontawesome sass
gem 'font-awesome-sass', '~> 5.3.1'


# forms
gem 'simple_form'
gem 'simplemde-rails'

# markdown
gem 'kramdown'

# notify don't tell - state machine
gem 'aasm'

# pagination
gem 'kaminari'

# s3
gem 'aws-sdk-s3', require: false

# pdf
gem 'prawn-rails'


# active storage
gem 'image_processing', '~> 1.2'
gem 'mini_magick'

add_source 'https://rails-assets.org' do
  gem 'rails-assets-bootstrap', '~> 4.1.0'
  gem 'rails-assets-bootstrap-datepicker'
  gem 'rails-assets-dropzone'
  gem 'rails-assets-font-awesome'
end

gem_group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  gem 'capybara-webkit'

  gem 'rspec-rails', '~> 3.6'

  gem 'spring'
  gem 'spring-commands-rspec'

  gem 'rubocop'

  gem 'pronto'
  gem 'pronto-flay'
  gem 'pronto-reek'
  gem 'pronto-rubocop'

  gem 'pry'

  gem 'binding_of_caller'
end

gem_group :test do
  gem 'rspec-activemodel-mocks'

  # instafailing RSpec formatter that uses a progress bar
  gem 'fuubar'

  # Collection of testing matchers extracted from Shoulda
  gem 'shoulda-matchers'

  gem 'rails-controller-testing'

  gem 'mutant-rspec'
end

gem_group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Annotate ALLTHETHINGS after migrations
  gem 'annotate'

  gem 'better_errors'
end

file '.nvmrc', <<-CODE
lts/carbon
CODE

file '.gitlab-ci.yml', <<-CODE
image: jrubisch/ci-images:rails-gitlab-chrome-2.4.2

services:
  - postgres:latest

variables:
  POSTGRES_DB: #{@app_name}_test
  POSTGRES_USER: runner
  POSTGRES_PASSWORD: ""

cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - vendor/ruby

before_script:
  # ruby / rails
  - ruby -v
  - which ruby
  - gem install bundler --no-ri --no-rdoc
  - RAILS_ENV=test bundle install --jobs $(nproc) --path vendor "${FLAGS[@]}"
  - bin/yarn install
  - cp config/database.yml.gitlab config/database.yml
  - RAILS_ENV=test bundle exec rake db:create db:schema:load

rspec:
  script:
    - RAILS_ENV=test xvfb-run -a bundle exec rspec

rubocop:
  script:
    - bundle exec pronto run -c=origin/develop --exit-code
CODE

file 'config/database.yml.gitlab', <<-CODE
default: &default
  adapter: postgresql
  encoding: unicode
  # For details on connection pooling, see Rails configuration guide
  # http://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

test:
  adapter: postgresql
  encoding: unicode
  pool: 5
  timeout: 5000
  host: postgres
  username: runner
  password: ""
  database: #{@app_name}_test
CODE

file '.flayignore', <<-CODE
db/*
db/migrate/*
app/helpers/submissions_helper.rb
app/controllers/people_controller.rb
spec/features/*
spec/controllers/*
spec/policies/*
CODE

file '.rubocop.yml', <<-CODE
AllCops:
  Exclude:
    - 'db/*'
    - 'db/migrate/*'
Metrics/BlockLength:
  Exclude:
    - 'spec/features/*'
Metrics/LineLength:
  Max: 120
Style/Documentation:
  Enabled: False
Style/FrozenStringLiteralComment:
  Enabled: False
Style/AsciiComments:
  Enabled: False
CODE

environment 'config.active_job.queue_adapter = :sidekiq'
environment 'config.webpacker.check_yarn_integrity = false', env: 'development'
environment 'config.webpacker.check_yarn_integrity = false', env: 'production'
environment 'config.action_mailer.default_url_options = { host: \'localhost:3000\' }', env: 'development'
environment 'config.assets.js_compressor = Uglifier.new(harmony: true)', env: 'production'

after_bundle do
  run 'rbenv local 2.5.1'
  run 'bundle exec rails webpacker:install'
  run 'bundle exec rails webpacker:install:stimulus'
  
  run 'bin/yarn add activestorage moment'

  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
