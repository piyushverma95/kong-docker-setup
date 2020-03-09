# kong-docker-setup with your custom plugin

	1. Starting PostgreSql Db in the container.

docker run -d --name kong-database \
-p 5432:5432 \
-e "POSTGRES_USER=kong" \
-e "POSTGRES_DB=kong" \
-e "POSTGRES_PASSWORD=kong" \
-v /home/ec2-user/kong-files/postgres-data:/var/lib/postgresql/data \
postgres:9.6

	2. Bootstrapping the Database

docker run --rm \
     -e "KONG_DATABASE=postgres" \
     -e "KONG_PG_HOST=172.17.0.2" \
     -e "KONG_PG_PASSWORD=kong" \
     -e "KONG_CASSANDRA_CONTACT_POINTS=172.17.0.2" \
     kong:latest kong migrations bootstrap

	3. Creating your Kong Image.

docker build -t kong:home ./

	4. Starting Kong in the container.

docker run -d --name kong-con \
     -e "KONG_DATABASE=postgres" \
     -e "KONG_PG_HOST=172.17.0.2" \
     -e "KONG_PG_PASSWORD=kong" \
     -e "KONG_CASSANDRA_CONTACT_POINTS=172.17.0.2" \
     -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
     -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
     -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
     -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
     -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
     -p 8000:8000 \
     -p 8443:8443 \
     -p 8001:8001 \
     -p 8444:8444 \
     kong:home

# Points:
	> /home/ec2-user/kong-files/postgres-data is the path on your machine where you want to store the database data permanently.
  		This helps when you stop and start your postgre container your data will still be there.
	> fortress-http-log & http-log-extended are custom plugins.
	> 172.17.0.2 is the Ip of postgre container
	> build kong:home image using the Dockerfile and entrypoint file. 
	> Make sure to make entrypoint.sh executable by giving it permissions before creating an image
	> I edited the image available on Docker Hub so that I can add the plugins.
  
# Sources: 
	Kong:latest image source: https://hub.docker.com/_/kong
	Kong:latest Dockerfile source: 	https://github.com/Kong/dockerkong/blob/7c6281ca1906b05080af23c94fafa2ff08d05856/ubuntu/Dockerfile
	fortress-http plugin: https://github.com/apifortress/fortress-http-log
	http-log-extended plugin: https://github.com/Makcy/kong-plugin-http-log-extended


