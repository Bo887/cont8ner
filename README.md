# Cont8ner

A set of scripts to create and delete a simple linux container in its own network/PID/mount namespace. 

Usage:

```./start_container.sh [container_name] [user_name] [image_path]```
- ```[container_name]``` will be the name of the new container and will be used as the name for the new namespaces.
- ```[user_name]``` will be the name of the non-root user created inside the container.
- ```[image_path]``` should be the path to the ```.tar.gz``` image.
- ```./start_container.sh``` will open a bash shell in the new container. 

```./remove_container.sh [container_name]```
- ```[container_name]``` should be the same name as the container created using ```./start_container.sh```.
