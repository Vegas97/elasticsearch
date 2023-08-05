Run the Elasticsearch Container:

To run Elasticsearch with Docker and ensure that it doesn't try to cluster (since you're running a single node), you should set the discovery.type to single-node. Also, remember to mount the volume for data persistence.


docker run --name elasticsearch -d -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -v /path/to/your/elasticsearch/data:/usr/share/elasticsearch/data docker.elastic.co/elasticsearch/elasticsearch:8.9.0


In the above command:

--name elasticsearch: gives the container a name for easier reference.
-d: runs the container in detached mode (in the background).
-p 9200:9200 -p 9300:9300: maps the ports from the container to your host.
-e "discovery.type=single-node": sets an environment variable to ensure Elasticsearch runs as a single node.
-v /path/to/your/elasticsearch/data:/usr/share/elasticsearch/data: mounts a volume for data persistence.
