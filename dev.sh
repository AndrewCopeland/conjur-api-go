#!/usr/bin/env bash

function finish {
  docker-compose down -v
}
trap finish EXIT

docker-compose pull postgres conjur
docker-compose build --pull
docker-compose up -d
docker-compose exec -T test ./wait_for_server.sh

api_key=$(docker-compose exec -T conjur rails r "print Credentials['cucumber:user:admin'].api_key")

# Run development environment
docker-compose exec test env \
    CONJUR_AUTHN_API_KEY=$api_key \
    bash -c "./convey.sh& bash"