#!/usr/bin/env bash

# check if Elasticsearch container is running
if [[ "$(docker ps -q -f name=elasticsearch)" == "" ]]; then
    echo "Elasticsearch container is not running. Please start it first."
    exit 1
fi

# Wait for Elasticsearch to be ready
status_code=$(curl --write-out '%{http_code}' --silent --output /dev/null http://localhost:9200/)

until [[ "$status_code" -eq 200 ]] || [[ "$status_code" -eq 401 ]]; do
    echo "Waiting for Elasticsearch..."
    sleep 5
    status_code=$(curl --write-out '%{http_code}' --silent --output /dev/null http://localhost:9200)
done

echo "Resetting password for elastic user..."
PASSWORD=$(docker exec -it elasticsearch /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic -b | tail -1)
echo "Password for elastic user: $PASSWORD"

echo "Generating enrollment token for Kibana..."
ENROLLMENT_TOKEN=$(docker exec -it elasticsearch /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -f -s kibana --url "http://127.0.0.1:9200"| tail -1)
docker exec -it elasticsearch /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana
echo "Enrollment token for Kibana: $ENROLLMENT_TOKEN"

# Saving secrets to a file
echo "ELASTIC_PASSWORD=$PASSWORD" > secrets.env
echo "KIBANA_ENROLLMENT_TOKEN=$ENROLLMENT_TOKEN" >> secrets.env

echo "Secrets saved to secrets.env. Make sure to keep this file safe and not commit it to version control."

