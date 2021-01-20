FROM alpine:3.6

# Set HOME environment to be used for Helm plugin installation
ENV HOME /

# Set version of Helm to download
ENV VERSION v3.4.1

WORKDIR /

# Add curl, git and bash for Helm plugins
RUN apk --update add curl git bash

# This is added to $PATH

# Install Helm
ENV FILENAME helm-${VERSION}-linux-amd64.tar.gz
ENV HELM_URL https://get.helm.sh/${FILENAME}

RUN echo $HELM_URL

RUN curl -o /tmp/$FILENAME ${HELM_URL} \
  && tar -zxvf /tmp/${FILENAME} -C /tmp \
  && mv /tmp/linux-amd64/helm /bin/helm \
  && rm -rf /tmp

# Install envsubst for yaml substitutions
ENV BUILD_DEPS="gettext"  \
    RUNTIME_DEPS="libintl"

RUN set -x && \
    apk add --update $RUNTIME_DEPS && \
    apk add --virtual build_deps $BUILD_DEPS &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps

# Install Helm plugins
# Workaround for an issue in updating the binary of `helm-diff`
ENV HELM_PLUGIN_DIR /.helm/plugins/helm-diff

# Plugin is downloaded to /tmp, which must exist
RUN mkdir /tmp

# Install Helm release plugin
RUN helm plugin install https://github.com/sstarcher/helm-release