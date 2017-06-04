# create-docker-keys
Utility to create docker swarm certificates

This utility creates the self-signed client and server certificates for a docker swarm

This process is described here:
https://docs.docker.com/engine/security/https/

To create the certificates, just map the work directory to your local disk
and execute this utility:

````bash
docker run -it --volume `pwd`/temp:/home/work uscdev/create-docker-keys
````

Enter the passphrase (password), full domain name and csr information.