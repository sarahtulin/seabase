rvm:
  - 2.0.0
  - 2.1.0
branches:
  only:
      - master
before_install:
  - sudo apt-get update
  - sudo apt-get install ncbi-blast+
before_script:
  - cp config/config.yml.example config/config.yml
  - bundle exec rake db:create:all
  - bundle exec rake db:migrate
  - bundle exec rake db:migrate HPS_ENV=test
script:
  - bundle exec rake
