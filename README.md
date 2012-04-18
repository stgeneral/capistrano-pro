# Capistrano::Pro

Capistrano recipes pack

## Features

* unicorn: server start, reload, stop tasks
* Assets: option to skip assets precompiling
* Managing `database.yml` Securely accoring to http://www.simonecarletti.com/blog/2009/06/capistrano-and-database-yml/

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano-pro', :git => 'git://github.com/web4pro/capistrano-pro.git'

And then execute:

    $ bundle

## Usage

In order to use capistrano-pro tasks you should use `bundle exec`

## Thanks to

* sosedoff/capistrano-unicorn

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
