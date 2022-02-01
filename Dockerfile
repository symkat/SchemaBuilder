FROM postgres:11

# cpanm Archive::Zip LWP::UserAgent happens on its own because these are required to install
# Crypt::Random's Math::Pari dep.
# DBD::Pg is being forced because https://github.com/bucardo/dbdpg/issues/83 hasn't been
# pushed to cpan yet.
RUN apt-get update \
    && apt-get install --yes libpq-dev liblocal-lib-perl cpanminus build-essential vim \
    && cpanm Archive::Zip LWP::UserAgent \
    && cpanm --force DBD::Pg \
    && cpanm DBIx::Class DBIx::Class::Schema::Loader DBIx::Class::Schema::Config DBD::Pg \
        Crypt::Random Crypt::Eksblowfish::Bcrypt DBIx::Class::InflateColumn::DateTime \
        DBIx::Class::InflateColumn::Serializer DBIx::Class::Schema::ResultSetNames

COPY build-schema /bin/build-schema
