ARG ruby_version

FROM ruby:${ruby_version} as base

ARG node_version="16"
ARG APP_VCS_REF

ENV APP_VCS_REF="${APP_VCS_REF}" \
    BUNDLE_IGNORE_CONFIG="true" \
    BUNDLE_JOBS="3" \
    # Ruby official image defines GEM_HOME
    BUNDLE_USER_HOME="${GEM_HOME}"

LABEL org.opencontainers.artifact.description="Duke University Libraries archives and manuscripts discovery UI"
LABEL org.opencontainers.image.url="https://archives.lib.duke.edu"
LABEL org.opencontainers.image.source="https://gitlab.oit.duke.edu/dul-its/dul-arclight"
# dul-arclight does not maintain an explicit version number(?)
# LABEL org.opencontainers.image.version="${APP_VERSION}"
LABEL org.opencontainers.image.revision="${APP_VCS_REF}"
LABEL org.opencontainers.image.vendor="Duke University Libraries"
LABEL org.opencontainers.image.license="Apache-2.0"

SHELL ["/bin/bash", "-c"]

RUN set -eux; \
	curl -sL https://deb.nodesource.com/setup_${node_version}.x | bash - ; \
	apt-get -y update; \
	apt-get -y install libpq-dev nodejs; \
        # Update Rubygems
	gem update --system; \
	npm install -g yarn

#------

FROM base as bundle

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./

RUN gem install bundler -v "$(tail -1 Gemfile.lock | tr -d ' ')" \
    && bundle install

#------

FROM base as app

ENV APP_ROOT="/opt/app-root" \
    APP_USER="app-user" \
    APP_UID="1001" \
    APP_GID="0" \
    FINDING_AID_DATA="/data" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    RAILS_ENV="production" \
    RAILS_PORT="3000" \
    TZ="US/Eastern"

WORKDIR $APP_ROOT

COPY . .

RUN set -eux; \
    apt-get -y install less locales wait-for-it; \
    apt-get -y clean; \
    rm -rf /var/lib/apt/lists/*

RUN echo "$LANG UTF-8" >> /etc/locale.gen; \
    locale-gen $LANG

VOLUME $FINDING_AID_DATA

RUN useradd -r -u $APP_UID -g $APP_GID -d $APP_ROOT -s /sbin/nologin $APP_USER; \
    chown -R $APP_UID:$APP_GID . $GEM_HOME $FINDING_AID_DATA

COPY --from=bundle --chown=$APP_UID:$APP_GID $GEM_HOME $GEM_HOME

USER $APP_USER

RUN SECRET_KEY_BASE=1 ./bin/rails assets:precompile

EXPOSE $RAILS_PORT

CMD ["./bin/rails", "server"]
