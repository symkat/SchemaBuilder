# SchemaBuilder

SchemaBuilder allows you to build an initial DBIx::Class schemas from postgresql `.sql` files.

A docker container with Postgres is loaded with with the file at `etc/schema.sql`, and another docker container mounts your current directory and runs a [DBIx::Class::Schema::Loader script](https://metacpan.org/pod/DBIx::Class::Schema::Loader).

## Create Your Schema

Create a new directory named after your schema.

```
$ mkdir My-Schema
$ cd My-Schema
$ mkdir {bin,etc}
```

Add the following script to `bin/create-classes`

```bash
#!/usr/bin/env bash

CLASS_NAME=$1

# Generate a random 8 character name for the docker container that holds the PSQL
# database.
PSQL_NAME=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z' | fold -w 8 | head -n 1)

# Launch a PSQL Instance
PSQL_DOCKER=`docker run --rm --name $PSQL_NAME -e POSTGRES_PASSWORD=dbic -e POSTGRES_USER=dbic -e POSTGRES_DB=dbic -d \
    --mount type=bind,src=$PWD/etc/schema.sql,dst=/docker-entrypoint-initdb.d/schema.sql postgres:11`

docker run --rm --link $PSQL_NAME:psqldb --mount type=bind,src=$PWD,dst=/app symkat/schema_builder /bin/build-schema $CLASS_NAME

docker kill $PSQL_DOCKER

sudo chown -R $USER:$USER lib
```

Create your schema in `etc/schema.sql`, this is an example.

```sql
CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE person (
    id                          serial          PRIMARY KEY,
    name                        text            not null,
    email                       citext          not null unique,
    is_enabled                  boolean         not null default true,
    created_at                  timestamptz     not null default current_timestamp
);

-- Settings for a given user.  | Use with care, add things to the data model when you should.
create TABLE person_settings (
    id                          serial          PRIMARY KEY,
    person_id                   int             not null references person(id),
    name                        text            not null,
    value                       json            not null default '{}',
    created_at                  timestamptz     not null default current_timestamp,

    -- Allow ->find_or_new_related()
    CONSTRAINT unq_person_id_name UNIQUE(person_id, name)
);
```

Once these files are in place, run `./bin/create-classes`

```
$ chmod u+x bin/create-classes
$ ./bin/create-classes My::Schema
symkat@localhost:~/code/SchemaBuilder$ ./bin/create-classes My::Schema
DBI connect('host=psqldb;dbname=dbic','dbic',...) failed: could not connect to server: Connection refused
	Is the server running on host "psqldb" (172.17.0.2) and accepting
	TCP/IP connections on port 5432? at /bin/build-schema line 8.
Connection failed, waiting 2 seconds before trying to connect.
Dumping manual schema for My::Schema to directory /app/lib ...
Schema dump completed.
d7840527960ad83b12bd98035755b9632afaaa58c96c8f2c58991e719906847a
$ tree
.
├── bin
│   └── create-classes
├── etc
│   └── schema.sql
├── lib
│   └── My
│       ├── Schema
│       │   └── Result
│       │       ├── Person.pm
│       │       └── PersonSetting.pm
│       └── Schema.pm
└── README.md
```

The schema libraries have been created.

Add a `dist.ini` to package it:

```ini
name    = My-Schema
author  = Your Name <you@example.com>
license = Perl_5
copyright_holder = Your Name
copyright_year   = 2021
abstract         = My::Schema Database

version = 0.001

[@Basic]

[Prereqs]
DBIx::Class::InflateColumn::Serializer = 0
DBIx::Class::Schema::Config            = 0
DBIx::Class::DeploymentHandler         = 0
MooseX::AttributeShortcuts             = 0
DBD::Pg                                = 0

[AutoPrereqs]
```

With this `dist.ini` file, a package can be built with `dzilla build`.
