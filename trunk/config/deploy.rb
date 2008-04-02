require 'erb'
require 'config/accelerator/accelerator_tasks'

set :application, "coworkination"
set :repository,  ""
set :user, 'admin' # this is the ssh user
set :deploy_to, "/home/#{user}/rails/apps/#{application}" # i like this location because the home directory is on the SAN and you can increase it's allocation easier than increasing the accelerator
set :scm, :subversion
set :scm_username, ''
set :scm_password, ''

set :domain, ''

role :app, domain
role :web, domain
role :db,  domain, :primary => true

set :server_name, "coworkination.com" # this is used in the apache conf
set :server_alias, "*.coworkination.com" # this is used in the apache donf

# the below are examples only, you can see how it would work if you want cap to test this before deploy
# depend :remote, :command, :gem
# depend :remote, :gem, :money, '>=1.7.1'
# depend :remote, :gem, :mongrel, '>=1.0.1'
# depend :remote, :gem, :image_science, '>=1.1.3'
# depend :remote, :gem, :rake, '>=0.7'
# depend :remote, :gem, :BlueCloth, '>=1.0.0'
# depend :remote, :gem, :RubyInline, '>=3.6.3'

after :deploy, 'deploy:cleanup' # i like this to keep the total file count down