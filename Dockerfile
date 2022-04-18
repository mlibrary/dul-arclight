ARG ruby_version

FROM ruby:${ruby_version} as base

SHELL ["/bin/bash", "-c"]

ENV BUNDLE_IGNORE_CONFIG="true" \
	BUNDLE_JOBS="3" \
	BUNDLE_USER_HOME="${GEM_HOME}"

RUN set -eux; \
	curl -sL https://deb.nodesource.com/setup_12.x | bash - ; \
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

RUN useradd -r -u $APP_UID -g $APP_GID -d $APP_ROOT -s /sbin/nologin $APP_USER; \
	chown -R $APP_UID:$APP_GID . $GEM_HOME

COPY --from=bundle --chown=$APP_UID:$APP_GID $GEM_HOME $GEM_HOME

USER $APP_USER

RUN SECRET_KEY_BASE=1 ./bin/rails assets:precompile

EXPOSE $RAILS_PORT

CMD ["./bin/rails", "server"]
