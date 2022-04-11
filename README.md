#  Curtiy Identity Server Quick Setup 

[![Quality](https://img.shields.io/badge/quality-experiment-red)](https://curity.io/resources/code-examples/status/)
[![Availability](https://img.shields.io/badge/availability-source-blue)](https://curity.io/resources/code-examples/status/)

A docker compose based curity identity server set up for local exploration and development purposes. 
It includes an external postgres datasource and comes pre-configured with devops dashboard enabled.

## Prepare the Installation

The system can be deployed on a MacOS or Windows workstation via a bash script, and has the following prerequisites:

* [Docker](https://docs.docker.com/get-docker/)
* [Docker compose](https://docs.docker.com/compose/install/)

Make sure you have above prerequisites installed and then copy a license file to the `idsvr-config/license.json` location.
If needed, you can also get a free community edition license from the [Curity Developer Portal](https://developer.curity.io).
 
## Installation

 1. Clone the repository
    ```sh
    git clone https://github.com/suren-khatana/docker-compose-local-setup.git
    cd docker-compose-local-setup
    ./build-env.sh
    ```
 2. Start & Stop 
    ```sh
     docker-compose start
     docker-compose stop
    ```
 3. Logs
    ```sh
     docker logs -f curity-idsvr
    ```
## Use the System

After the installation is completed, you will have a fully working system:

- [OAuth and OpenID Connect Endpoints](https://localhost:8443/~/.well-known/openid-configuration) used by applications
- A rich [Admin UI](https://localhost:6749/admin) for configuring applications and their security behavior
- A SQL based postgres database from which users, tokens, sessions and audit information can be queried
- A [SCIM 2.0 API & GraphQL](https://localhost:6749/admin/#/profiles/user-management/user-management/endpoints) endpoints for managing user accounts
- A working [DevOps dashboard](https://localhost:6749/admin/dashboard) for delegated administration



## More Information

Please visit [curity.io](https://curity.io/) for more information about the Curity Identity Server.