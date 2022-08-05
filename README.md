
## prerequisite

  redis -> redis server should be up and running

  postgresql -> postgres server should be up and running

  ruby 2.6.6 -> required ruby version should be installed

  postman
## setup

  To setup run below commands

  `bundle`

  `rake db:setup`

  `bundle exec sidekiq -r ./config/sidekiq.rb -C ./config/sidekiq.yml`

## run server

  To run server use following command

  `bundle exec puma`

## rspec

  To run rspec run following commands

  `APP_ENV=test bundle exec puma`

  > In another terminal tab run

  `rspec`

## API collection

  [API collection](umai-assessment.postman_collection.json)
