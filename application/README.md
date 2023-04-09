# A simple Hello World application

### Overview

This is a simple Python app meant to be run as an image inside a container.

App returns a simple "Hello Goldbach from BastovanSurcinski" when a GET request is sent to a URL that will be provided at the time of running the configuration.

### Continuous Integration

The app uses Github Actions for its CI. The CI consists of the following steps:

1. Run Python lint against the code
2. Run Python unittests
3. Run Hadolint against the Dockerfile
4. Build the image
5. Run semantic-release against it to version it nicely
6. Tag the image with the proper version and push it to Docker Hub
7. Publish the version change to the infrastructure repo