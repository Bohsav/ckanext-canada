# README

Dockerfile to build open-data/ckanext-canada.

Build stages available:

- base: base CKAN only, built from CKAN open-data's fork on canada-v2.10 branch.
- public: CKAN extended with ckanext-canada built for public setup.
- (default) registry: CKAN extended with ckanext-canada built for registry
  setup.

Setup attempts to use sane default config values, but it should be tailored for
specific use using `envvars`.
