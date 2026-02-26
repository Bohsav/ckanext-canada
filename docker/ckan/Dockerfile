# Build CKAN with this extension embedded
# Copy of https://github.com/ckan/ckan-docker-base
# Adapted to build CKAN Canada's fork (https://github.com/open-data/ckan/tree/canada-v2.10)

# NOTE: Development build stripped. Only base and ext for extension are available

# base, ext
ARG ENV=ext

FROM python:3.10-slim-bookworm AS python

# ┌─────────────────────────────────────────────────────────────┐
# │                                                             │
# │ Base image (Production env)                                 │
# │ ---------------------------                                 │
# │ This is always built                                        │
# │                                                             │
# └─────────────────────────────────────────────────────────────┘

FROM python AS base

# Always build CKAN canada-v2.10
ENV CKAN_REF="canada-v2.10"

# Internals, you probably don't need to change these
ENV TZ=UTC
ENV APP_DIR=/srv/app
ENV SRC_DIR=${APP_DIR}/src
ENV CKAN_INI=${APP_DIR}/ckan.ini
ENV PIP_SRC=${SRC_DIR}
ENV CKAN_STORAGE_PATH=/var/lib/ckan
# Build the fork
ENV GIT_URL=https://github.com/open-data/ckan.git

# Customize these in the environment (.env) file if needed
ENV CKAN_SITE_URL=http://localhost:5000
# Do not assume any plugins
# ENV CKAN__PLUGINS="image_view text_view recline_view datastore envvars"

# UWSGI options
ENV UWSGI_HARAKIRI=50

WORKDIR ${APP_DIR}

# Set up timezone
RUN echo ${TZ} > /etc/timezone 

# Set LC_ALL=en_US.UTF-8 will ensure that all locale-dependent operations in the current environment
# will use English language and United States cultural conventions with UTF-8 character encoding
ENV LC_ALL=en_US.UTF-8

# Set the locale
RUN apt-get update 
RUN apt-get install --no-install-recommends -y locales 
RUN sed -i "/$LC_ALL/s/^# //g" /etc/locale.gen 
RUN dpkg-reconfigure --frontend=noninteractive locales 
RUN update-locale LANG=${LC_ALL}

# Install system libraries
RUN apt-get install --no-install-recommends -y \
        apt-utils \
        git \
        libpq-dev \
        g++ \
        linux-headers-generic \
        libtool \
        patch \
        wget 

# Create the src directory
RUN mkdir -p ${SRC_DIR} 

# Install supervisord and create the supervisord.d directory
RUN apt-get install --no-install-recommends -y \
        supervisor && \
        mkdir -p /etc/supervisord.d 

COPY setup/supervisord.py3.conf /etc/supervisord.conf

# Install uwsgi, the CKAN application, the dependency packages for CKAN plus some confiquration
RUN pip3 install -U pip && \
    pip3 install -U "setuptools==81" && \
    pip3 install uwsgi && \
    cd ${SRC_DIR} && \
    pip3 install -e git+${GIT_URL}@${CKAN_REF}#egg=ckan && \
    cd ckan && \
    pip3 install --no-binary markdown -r requirements.txt && \
    # Install CKAN envvars to support loading config from environment variables
    pip3 install -e git+https://github.com/okfn/ckanext-envvars.git@v0.0.6#egg=ckanext-envvars && \
    # Create and update CKAN config
    ckan generate config ${CKAN_INI} && \
    ckan config-tool ${CKAN_INI} "beaker.session.secret = " && \
    ckan config-tool ${CKAN_INI} "ckan.plugins = ${CKAN__PLUGINS}" 

# Create ckan and ckan-sys users and the ckan-sys group plus set up the storage path
RUN groupadd -g 502 ckan-sys && \
    useradd -rm -d /srv/app -s /bin/bash -g ckan-sys -u 502 ckan-sys && \
    useradd -rm -d /srv/app -s /bin/bash -g ckan-sys -u 503 ckan 

COPY setup/prerun.py ${APP_DIR}
COPY setup/start_ckan.sh ${APP_DIR}
ADD https://raw.githubusercontent.com/open-data/ckan/${CKAN_REF}/wsgi.py ${APP_DIR}
RUN chmod 644 ${APP_DIR}/wsgi.py 

# Create entrypoint directory for children image scripts
RUN mkdir -p /docker-entrypoint.d && chmod 755 /docker-entrypoint.d 

# Set the ownership of the app directory, usr/local and the entrypoint directory to the ckan-sys user
RUN chown -R ckan-sys:ckan-sys ${APP_DIR} && \
    chown -R ckan-sys:ckan-sys /docker-entrypoint.d && \
    chown -R ckan-sys:ckan-sys /usr/local 

# Set the ownership of the CKAN config file, src and the storage path to the ckan user
RUN chown ckan:ckan-sys ${APP_DIR}/ckan.ini && \
    chown -R ckan:ckan-sys ${APP_DIR}/src && \
    mkdir -p ${CKAN_STORAGE_PATH} && \
    chown -R ckan:ckan-sys ${CKAN_STORAGE_PATH} 

USER ckan

EXPOSE 5000

HEALTHCHECK --interval=60s --timeout=5s --retries=5 CMD curl --fail http://localhost:5000/api/3/action/status_show || exit CMD ["/srv/app/start_ckan.sh"]

CMD ["/srv/app/start_ckan.sh"]

FROM base AS ext

# Adapted from ckan-docker repo (https://github.com/ckan/ckan-dockerc)

USER root

# Make it cache friendly
WORKDIR ${SRC_DIR}
RUN pip3 install -U pip 
# --- Requirements ckanext-canada ---
RUN pip3 install -e git+https://github.com/ckan/ckanapi.git@master#egg=ckanapi 
RUN pip3 install -r ckanapi/requirements.txt 
RUN pip3 install -e git+https://github.com/ckan/ckanext-scheming@master#egg=ckanext-scheming 
RUN pip3 install -e git+https://github.com/open-data/ckanext-recombinant@master#egg=ckanext-recombinant 
RUN pip3 install -r ckanext-recombinant/requirements.txt 
RUN pip3 install -e git+https://github.com/open-data/ckanext-fluent@master#egg=ckanext-fluent 
# NOTE: requirements for ckanext-fluent are installed separately
RUN pip3 install six 
#
RUN pip3 install -e git+https://github.com/open-data/ckanext-security.git@${CKAN_REF}#egg=ckanext-security 
RUN pip3 install -r ckanext-security/requirements.txt 
RUN pip3 install -e git+https://github.com/open-data/ckanext-validation.git@${CKAN_REF}#egg=ckanext-validation 
RUN pip3 install -r ckanext-validation/requirements.txt 
RUN pip3 install -e git+https://github.com/open-data/ckanext-xloader.git@${CKAN_REF}#egg=ckanext-xloader 
RUN pip3 install -r ckanext-xloader/requirements.txt 
RUN pip3 install -e git+https://github.com/open-data/ckanext-cloudstorage.git@${CKAN_REF}#egg=ckanext-cloudstorage 
RUN pip3 install -r ckanext-cloudstorage/requirements.txt 
RUN pip3 install -e git+https://github.com/open-data/ckanext-dcat.git@${CKAN_REF}#egg=ckanext-dcat 
RUN pip3 install -r ckanext-dcat/requirements.txt 
RUN pip3 install -e git+https://github.com/open-data/ckanext-power-bi.git@main#egg=ckanext-power-bi 
RUN pip3 install -r ckanext-power-bi/requirements.txt 
RUN pip3 install -e git+https://github.com/open-data/ckanext-openapiview.git@main#egg=ckanext-openapiview 
RUN pip3 install -e git+https://github.com/open-data/ckanext-gcnotify.git@master#egg=ckanext-gcnotify 
RUN pip3 install -r ckanext-gcnotify/requirements.txt 
RUN pip3 install -e git+https://github.com/open-data/ckanext-citeproc.git@main#egg=ckanext-citeproc 
RUN pip3 install -r ckanext-citeproc/requirements.txt 
RUN pip3 install -e git+https://github.com/open-data/ckanext-dsaudit.git@master#egg=ckanext-dsaudit 
# Additional dependencies
RUN pip3 install --force-reinstall git+https://github.com/open-data/frictionless-py.git@${CKAN_REF}#egg=frictionless
RUN pip3 install -U requests[security]
# Install ckanext-canada theming
RUN pip3 install -e git+https://github.com/open-data/ckanext-canada.git@master#egg=ckanext-canada 
RUN pip3 install -r ckanext-canada/requirements.txt 
# ckanext-canda: upgrade bad requirement
RUN pip3 install --force-reinstall git+https://github.com/jazzband/geojson.git@3.0.0#egg=geojson 
RUN pip3 install --force-reinstall git+https://github.com/chardet/chardet.git@5.2.0#egg=chardet 
WORKDIR /

# Copy security config
COPY --chown=ckan-sys:ckan-sys who.ini ${APP_DIR}/who.ini
COPY --chown=ckan-sys:ckan-sys who-security.ini ${APP_DIR}/who-security.ini

COPY --chown=ckan-sys:ckan-sys local-extensions ${SRC_DIR}/local-extensions

RUN for dir in `ls ${SRC_DIR}/local-extensions`; do \
    echo "Installing ${dir}" \
    && pip3 install -e ${SRC_DIR}/local-extensions/${dir}/. \
    && pip3 install -r ${SRC_DIR}/local-extensions/${dir}/requirements.txt; \
    done; 

# Copy custom init scripts for container
COPY --chown=ckan-sys:ckan-sys docker-entrypoint.d/* /docker-entrypoint.d/

# Copy patches
COPY --chown=ckan-sys:ckan-sys patches ${APP_DIR}/patches

# Copy overrides as necessary
COPY --chown=ckan-sys:ckan-sys setup.override/prerun.py.override ${APP_DIR}/prerun.py
COPY --chown=ckan-sys:ckan-sys setup.override/start_ckan.sh.override ${APP_DIR}/start_ckan.sh

# Ownership chages
RUN mkdir -p ${APP_DIR} /etc/ckan /var/lib/ckan \
    && chgrp -R 0 ${APP_DIR} /etc/ckan /var/lib/ckan \
    && chmod -R g+rwX ${APP_DIR} /etc/ckan /var/lib/ckan \
    && chmod g+s ${APP_DIR} /etc/ckan /var/lib/ckan; 

RUN chmod g+rx ${APP_DIR}/start_ckan.sh;

COPY --chown=ckan-sys:ckan-sys ckanext-canada-base-conf.ini ${APP_DIR}/merge-conf.ini

USER ckan

# Merge default config
RUN ckan config-tool ${CKAN_INI} -f ${APP_DIR}/merge-conf.ini 

# Apply patches
RUN for d in $APP_DIR/patches/*; do \
        if [ -d $d ]; then \
            for f in `ls $d/*.patch | sort -g`; do \
                cd $SRC_DIR/`basename "$d"` && echo "$0: Applying patch $f to $SRC_DIR/`basename $d`"; patch -p1 < "$f" ; \
            done ; \
        fi ; \
    done
