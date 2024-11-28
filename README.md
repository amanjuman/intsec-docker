# Passoire Docker Container

This repository contains a `Dockerfile` to build and run the Passoire Docker container. Follow the instructions below to set up and run the container.

---

 Table of Contents
- [Getting Started](#getting-started)
- [Building the Docker Image](#building-the-docker-image)
- [Running the Docker Container](#running-the-docker-container)
- [Contributing](#contributing)
- [License](#license)

---

## Getting Started

To use this repository, you will need:
- [Docker](https://www.docker.com/get-started) installed on your system.

### Clone the Repository
First, clone the repository:
```
git clone https://github.com/amanjuman/intsec-docker.git
cd passoire
```

## Building the Docker Image
To build the Docker image, run the following command in the root directory of the repository (where the Dockerfile is located):

```
docker build -t g10/passoire:latest .
This command will create a Docker image with the tag g10/passoire:latest.
```

## Running the Docker Container
To run the container, use the following command:
```
docker run -d \
  --name=passoire \
  --hostname=passoire \
  -p 1022:22 \
  -p 1080:80 \
  --restart unless-stopped \
  g10/passoire:latest
```

## Explanation of Flags:
-d: Run the container in detached mode.

--name=passoire: Assigns the container a custom name (passoire).

--hostname=passoire: Sets the hostname of the container to passoire.

-p 1022:22: Maps port 22 inside the container to port 1022 on the host machine.

-p 1080:80: Maps port 80 inside the container to port 1080 on the host machine.

--restart unless-stopped: Ensures the container restarts automatically unless explicitly stopped.

## Contributing
We welcome contributions! Please follow these steps:

## Fork the repository.
Create a new branch for your feature or bugfix.
Submit a pull request with a detailed description of your changes.

## License
This project is licensed under the MIT License.
