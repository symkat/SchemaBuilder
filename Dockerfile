FROM postgres:13

RUN apt-get update \
    && apt-get install --yes libpq-dev liblocal-lib-perl cpanminus build-essential vim \
    && cpanm DBIx::Class DBIx::Class::Schema::Loader DBIx::Class::Schema::Config DBD::Pg \
        Crypt::Random Crypt::Eksblowfish::Bcrypt DBIx::Class::InflateColumn::DateTime \
        DBIx::Class::InflateColumn::Serializer DBIx::Class::Schema::ResultSetNames Data::GUID

COPY build-schema /bin/build-schema
