# UDB

UDB (Unified Database) acts as a gateway between your database and your applications. It provides a simple yet powerful API to interact with your database.

## Configuration

UDB is expecting the Database settings with the following env variable:
 - PORT: port the socket will be accepting connections
 - DB_HOST: Database hostname
 - DB_NAME: Database name
 - DB_USER: POSTGRESQL user name
 - DB_PASS: POSTGRESQL password
 - DB_PORT: port where postgresql is waiting for connection
