FROM golang:1.6

ENV DEBIAN_FRONTEND noninteractive
RUN sed -i '1i deb     http://gce_debian_mirror.storage.googleapis.com/ wheezy         main' /etc/apt/sources.list
RUN apt-get update -y && apt-get install -y -qq --no-install-recommends wget unzip openssh-client curl build-essential ca-certificates git mercurial bzr python-openssl && apt-get clean

WORKDIR /

# Install the Google Cloud SDK.
ENV HOME /
ENV CLOUDSDK_PYTHON_SITEPACKAGES 1
RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.zip && unzip google-cloud-sdk.zip && rm google-cloud-sdk.zip

# Lock the Google Cloud SDK version.
ENV CLOUDSDK_COMPONENT_MANAGER_FIXED_SDK_VERSION 0.9.82
RUN google-cloud-sdk/install.sh --usage-reporting=true --path-update=true --bash-completion=true --rc-path=/.bashrc --additional-components app-engine-java app-engine-python app kubectl alpha beta pkg-go pkg-python pkg-java preview

# Disable updater check for the whole installation.
# Users won't be bugged with notifications to update to the latest version of gcloud.
RUN google-cloud-sdk/bin/gcloud config set --installation component_manager/disable_update_check true || google-cloud-sdk/bin/gcloud config set component_manager/disable_update_check true

# Disable updater completely.
# Running +--------------------------------------------------------+
|           These components will be updated.            |
+---------------------------------+------------+---------+
|               Name              |  Version   |   Size  |
+---------------------------------+------------+---------+
| BigQuery Command Line Tool      |     2.0.24 | < 1 MiB |
| Cloud SDK Core Libraries        | 2016.05.13 | 4.0 MiB |
| Cloud Storage Command Line Tool |       4.19 | 2.6 MiB |
| gcloud app Python Extensions    |     1.9.37 | 7.2 MiB |
+---------------------------------+------------+---------+
+----------------------------------------------------------------------------+
|                    These components will be installed.                     |
+-----------------------------------------------------+------------+---------+
|                         Name                        |  Version   |   Size  |
+-----------------------------------------------------+------------+---------+
| BigQuery Command Line Tool (Platform Specific)      |     2.0.24 | < 1 MiB |
| Cloud SDK Core Libraries (Platform Specific)        | 2016.03.28 | < 1 MiB |
| Cloud Storage Command Line Tool (Platform Specific) |       4.18 | < 1 MiB |
| kubectl (Linux, x86_64)                             |      1.2.4 | 8.2 MiB |
+-----------------------------------------------------+------------+---------+ doesn't really do anything in a union FS.
# Changes are lost on a subsequent run.
RUN sed -i -- 's/\"disable_updater\": false/\"disable_updater\": true/g' /google-cloud-sdk/lib/googlecloudsdk/core/config.json || echo nope, too soon for this

RUN mkdir /.ssh
ENV PATH /google-cloud-sdk/bin:$PATH
VOLUME ["/.config"]
CMD bash

# install go appengine sdk
RUN wget https://storage.googleapis.com/appengine-sdks/featured/go_appengine_sdk_linux_amd64-1.9.37.zip &&     unzip go_appengine_sdk_linux_amd64-1.9.37.zip
ENV PATH $PATH:/go_appengine

