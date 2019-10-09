# TL;DR;

```bash
cd test
docker-compose run pentaho-kettle
```

* Will test environment variables
* Will test a postgres JNDI connection to a provided postgres container

# Quickstart

* Mount your project;
* Pass configurations (jvm-env, jndi, aws, memory) as env vars
* Run!

The entry point is a special `run.sh` file that receives the following run arguments:

* **Run command**
* `(trans|job)` - will call kitchen or pan accordingly
* `file_path` - maps to the complete path of your job or transformation - internally to the container
* **Other args** - will be forwarded to PDI command line; you can pass named parameters or other arguments that pan.sh or kitchen.sh can receive

Example usage on docker-compose.yml: 

```yml
  # Will call kitchen and pass main.kjb as a definition
  command: job /pentaho/project/main.kjb
```

# Docker image for Kettle (batch)

The main purpose here is to have one image works for many environments, reducing the need to create one image per environment.

You'll be able to setup on runtime some aspects like:

## Kettle env vars

> `~/.kettle/kettle.properties`

Every environment variable provided to the container starting with the prefix `_ENV_` will have the `_ENV_` part stripped from its key and persisted into the **kettle.properties** file.

The following environment variables, when provided to docker runtime:

```properties
_ENV_BUCKET_NAME=dev_buckets
_ENV_DATABASE_NAME=development
```

... would output this into the kettle.properties file:

```properties
BUCKET_NAME=dev_buckets
DATABASE_NAME=development
```

## AWS Credentials
> `~/.aws/credentials` 

Variables preffixed with `_AWS_` will end up in the aws credentials file. So if you'd like set your credentials for a container, you should provide two env vars:

```properties
_AWS_aws_access_key_id=MYID
_AWS_aws_secret_access_key=MYKEY
```

This would end up in the file like:

```properties
aws_access_key_id=MYID
aws_secret_access_key=MYKEY
```

The file will always have the default header `[default]`. 

## JNDI connections

JNDI Connections are stored into the file `data-integration/simple-jndi/jdbc.properties` and enable Pentaho ETL developers to simply use an alias (called JNDI) in the connection dialog so that credentials and access info aren't stored everywhere.

The rules for correctly populating the jndi file are:

* You need to preffix the environment variables with `_JNDI_`;
* Make sure to provide env.vars for each JNDI property (type, driver, url, user, password)
* Instead of `/` after the jndi name, use `_`.
    * for `aws_dw/driver=com.amazon.redshift.jdbc4.Driver`; you should use:
    * --> `aws_dw_driver=com.amazon.redshift.jdbc4.Driver`1. 

Example vars:

```properties
_JNDI_live_logging_info_type=javax.sql.DataSource
_JNDI_live_logging_info_driver=org.postgresql.Driver
_JNDI_live_logging_info_url=jdbc:postgresql://localhost:5432/hibernate
_JNDI_live_logging_info_user=hibuser
_JNDI_live_logging_info_password=password
```

... will generate the properties file:

```properties
live_logging_info/type=javax.sql.DataSource
live_logging_info/driver=org.postgresql.Driver
live_logging_info/url=jdbc:postgresql://localhost:5432/hibernate
live_logging_info/user=hibuser
live_logging_info/password=password
```

And you'll be able to use **live_logging_info** as a JNDI alias in your jobs and transformations.

Multiple JNDI connections can be set for a container.

## JVM Memory

The maximum memory to the jvm `-Xmx` param can be configured by setting up an environment variable named `_RUN_XMX`.

Considerations:

* You should use the value using megabytes; ex.: `2048` for 2g
* If no variable is provided, the jvm runs with 2048m;
