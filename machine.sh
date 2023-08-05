#!/usr/bin/env bash

if [[ "$(docker network ls | grep "elastic")" == "" ]]; then
    docker network create --driver=bridge --ipam-driver=default --subnet=172.33.1.0/24 --gateway=172.33.1.1 elastic
fi

docker compose up -d

# Wait for Elasticsearch to fully start
echo "Waiting for Elasticsearch to start..."
sleep 5  # Adjust this as necessary

while true; do
    # Check if the pattern exists in the logs
    if docker logs elasticsearch 2>&1 | tail -r | grep -q "✅  Elasticsearch security features have been automatically configured!"; then
        break
    fi

    # Wait for a few seconds before checking again
    sleep 5
done

# Get logs from Elasticsearch container and extract password and token using tail -r
PASSWORD=$(docker logs elasticsearch 2>&1 | tail -r | grep -m1 "Password for the elastic user" | awk -F': ' '{print $2}')
TOKEN=$(docker logs elasticsearch 2>&1 | tail -r | grep -m1 -A1 'Copy the following enrollment token and paste it into Kibana' | tail -1)

# Wait for Kibana to fully start
echo "Waiting for Kibana to start..."
sleep 5  # Adjust this as necessary

while true; do
    # Check if Kibana URL pattern exists in the logs
    if docker logs kibana 2>&1 | tail -r | grep -qE 'http://0.0.0.0:5601/\?code=[0-9]+'; then
        break
    fi

    # Wait for a few seconds before checking again
    sleep 5
done

# Get logs from Kibana container and extract the URL using tail -r
KIBANA_URL=$(docker logs kibana 2>&1 | tail -r | grep -m1 -Eo 'http://0.0.0.0:5601/\?code=[0-9]+')

# Write to .env file
echo "ELASTIC_PASSWORD=$PASSWORD" > .env
echo "ENROLLMENT_TOKEN=$TOKEN" >> .env
echo "KIBANA_URL=$KIBANA_URL" >> .env

echo "Secrets saved to .env. Make sure to keep this file safe and not commit it to version control."

docker exec -it elasticsearch /bin/bash
