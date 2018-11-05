# General Transit Feed Specification (GTFS) Rails API

This Ruby on Rails application provides a JSON API representation of the data contained in a given GTFS feed from a local transit provider.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

# Requirements

## Production
- Ruby 2.5+
- Bundler
- MySQL

## Development

_All of the requirements above are spec'd out in the `Dockerfile` and `docker-compose.yml` files._

- [Docker](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

# Installation

1. Clone the repository into a project directory
1. Copy `.env-dist` to `.env` and update connection information
1. Run `docker-compose up -d` to bring up the web server and database server
1. Run `docker exec -it gtfs-rails-api-web bash` to access running instance
1. Run `bundle exec rake db:setup` to create the database and run the migrations
1. Run `bundle exec rake import:all` to process the data from the GTFS feed
1. Browse to `http://localhost:3000` to browse API endpoints
