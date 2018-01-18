Heroku buildpack to start a Datomic Transactor
==============================================

## What this buildpack does

- obtains and packages Datomic

- prepares Datomic storage configurations

- starts the Datomic transactor

The rest of this README explains the necessary configuration.

> Please check out an associated [blog post](http://blog.opengrail.com/datomic/heroku/dynamodb/aws/2016/01/03/datomic-heroku-spaces.html) providing more background

## Heroku pre-requisites

This technology exploits the features of [Heroku Spaces](https://www.heroku.com/private-spaces) to securely inter-connect dynos. 

To use this buildpack you need to have access to Heroku Spaces. Outside of Heroku Spaces, Datomic security is not assured.

## Configuring a custom buildpack

To enable this buildpack on an existing project:

````heroku buildpacks:set https://github.com/opengrail/heroku-buildpack-datomic -a myapp````

For more options and information see the [Heroku web site on third party buildpacks](https://devcenter.heroku.com/articles/third-party-buildpacks#using-a-custom-buildpack)

## Detection

The buildpack will detect that you wish to start a Datomic transactor if your project has a Procfile in its top level directory that has this line:

````datomic: /app/scripts/start-datomic.sh````

## Configuration

### Datomic free configuration - playtime only!!

By default Datomic free will be started. *Data will not be stored between startups*

By default the version of Datomic is the latest published version with `0.9.5344` as a fallback if the latest version cannot be detected for some reason.

You can optionally configure the version of Datomic you wish to deploy.

````heroku config:set DATOMIC_VERSION=version-number````

### Datomic Pro configuration

You can get a free copy of the [Datomic Pro starter edition](http://www.datomic.com/get-datomic.html) or bring your supported license.

````heroku config:set DATOMIC_LICENSE_PASSWORD=license-password````

````heroku config:set DATOMIC_LICENSE_USER=license-user````

````heroku config:set DATOMIC_TRANSACTOR_KEY=license-key````

By default the version of Datomic is the latest published version with `0.9.5344` as a fallback if the latest version cannot be detected for some reason.

You can optionally configure the version of Datomic you wish to deploy.

````heroku config:set DATOMIC_VERSION=version-number````

### Storage options

The buildpack has support for `Heroku Postgres` and `Amazon DynamoDB`

````heroku config:set DATOMIC_STORAGE_TYPE=storage_type````

where storage_type is `HEROKU_POSTGRES` or `DYNAMODB`.

By default the buildpack will try to configure for `HEROKU_POSTGRES`

### Heroku Postgres - Pro editions only

The only Postgres database supported is `Heroku Postgres (free or paid)`

This buildpack will automatically configure Postgres for use with Datomic (if not already done) 

### Amazon DynamoDB - Pro editions only

We aim for simplicity in this buildpack so we reuse the [defaults for DynamoDB that Datomic supports](http://docs.datomic.com/storage.html#provisioning-dynamo).

This buildpack will check that DynamoDB is configured for use with Datomic using the automated setup that Datomic provides.

To provide your Amazon account details to Heroku set the configuration variables for your app like this:

````heroku config:set AWS_ACCESS_KEY_ID=aws-access-key-id AWS_SECRET_KEY=aws-secret-key````

## Dyno size

The buildpack defaults to 2Gb RAM. In production, 4Gb or more is preferred. See [Datomic documentation on capacity planning](http://docs.datomic.com/capacity.html).

## Dyno count - theoretical

*I have not proven this failover so you will need to work with Cognitect to obtain proper assurances*

In theory, to manage failover for the Pro edition (not starter or free), 2 transactor workers can be started.

```heroku ps:scale datomic=2```

Consult the [Datomic High Availability documentation](http://docs.datomic.com/ha.html) for more details.

## ToDo

- [X] Enable further configuration such as JVM memory

- [ ] support other SQL DBs [ postgres and Oracle on Amazon RDS, MySQL Heroku addons (cleardb and jawsdb) ]

- [ ] support cassandra via Heroku addon (Instaclustr)

## Basis

This is forked from the official [Heroku buildpack](http://devcenter.heroku.com/articles/buildpack) for Java apps.

## Contributors

Thanks to the following GitHub users for providing PRs

- @matthavener [PR #1]
- @a613 [PR #2]

License
-------

Licensed under the MIT License. See LICENSE file.
