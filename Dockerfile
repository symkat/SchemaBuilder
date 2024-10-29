FROM postgres:15

# Module::Pluggable::Object is a required dep, however it fails the test t/28appledouble.t
# We're going to go ahead and force the install.

RUN apt-get update \
    && apt-get install --yes libpq-dev liblocal-lib-perl cpanminus build-essential vim \
    && cpanm --force Module::Pluggable::Object  \
    && cpanm DBIx::Class DBIx::Class::Schema::Loader DBIx::Class::Schema::Config DBD::Pg \
        Crypt::Random Crypt::Eksblowfish::Bcrypt DBIx::Class::InflateColumn::DateTime \
        DBIx::Class::InflateColumn::Serializer DBIx::Class::Schema::ResultSetNames \
        Data::GUID Time::Duration

COPY build-schema /bin/build-schema
