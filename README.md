# Docker image for Kettle (batch)

The main purpose here is to have one image work for many environments, reducing the need to create one image per environment.

You'll be able to setup on runtime some aspects like:

1. `~/.kettle/kettle.properties` (Kettle environment variables) - Every environment variable provided to the container starting with the prefix `_ENV_` will have the `_ENV_` part stripped from its key and persisted into the `~/.kettle/kettle.properties`; example:
     * Docker `_ENV_BUCKET_NAME=dev_buckets`;
     * Kettle.properties -> `BUCKET_NAME=dev_buckets`
2. `~/.aws/credentials` Variables preffixed with `_AWS_` will end up in this file. So if you'd like to store your credentials for a container, you should provide two env vars, `_AWS__AWS_aws_access_key_id` and `_AWS_aws_secret_access_key`. The file will always have the default header `[default]`. Here's how the preffixes are deleted on each var:
     * Docker env `_AWS_aws_access_key_id=1233455676897980`
     * Credentials corresponding line `aws_access_key_id=1233455676897980`
3. JNDIs - you can output content to the file `data-integration/simple-jndi/jdbc.properties`
      * You just need to preffix the environment variables with `_JNDI_`;
      * Make sure to provide env.vars for each JNDI property (type, driver, url, user, password)
      * Instead of `/` after the jndi name, use `_`.
        * for `aws_dw/driver=com.amazon.redshift.jdbc4.Driver`; you should use:
        * --> `aws_dw_driver=com.amazon.redshift.jdbc4.Driver`
4. Maximum memory to the jvm `-Xmx` param
      * The environment variable read is `_RUN_XMX`
      * You should use the value using megabytes; ex.: `2048` for 2g
      * If no variable is provided, the jvm runs with 2048m;

# Todo

* Create the run.sh entry point
* Chain the file `runtime-config.sh` to configure the variables files;
* consider not changing the file `spoon.sh` and documenting the use of `$PENTAHO_DI_JAVA_OPTIONS` instead.
* Test and document the correct usage considering mounting a project, passing vars to the repo and running a transformation/job passing parameters
