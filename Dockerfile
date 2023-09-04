FROM ubuntu:22.04

RUN apt update
RUN apt upgrade -y

RUN apt -y install git \
  curl \
  autoconf \
  bison \
  build-essential \
  libssl-dev \
  libyaml-dev \
  libreadline6-dev \
  zlib1g-dev \
  libncurses5-dev \
  libffi-dev \
  libgdbm6 \
  libgdbm-dev \
  libdb-dev \
  apt-utils

ENV RBENV_ROOT /usr/local/src/rbenv
ENV RUBY_VERSION 3.1.2
ENV PATH ${RBENV_ROOT}/bin:${RBENV_ROOT}/shims:$PATH

RUN git clone https://github.com/rbenv/rbenv.git ${RBENV_ROOT} \
  && git clone https://github.com/rbenv/ruby-build.git \
  ${RBENV_ROOT}/plugins/ruby-build \
  && ${RBENV_ROOT}/plugins/ruby-build/install.sh \
  && echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh

RUN rbenv install ${RUBY_VERSION} \
  && rbenv global ${RUBY_VERSION}

RUN gem install jekyll -v '3.9.3'

RUN apt install -y curl && \
  curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && \
  apt install -y nodejs

RUN git config --global user.name "${GIT_USER_NAME}" && \
  git config --global user.email "${GIT_USER_EMAIL}" && \
  git config --global core.editor "${GIT_CORE_EDITOR}" && \
  git config --global --add safe.directory /workspaces/sgryt.com
