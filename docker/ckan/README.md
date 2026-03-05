# README

Dockerfile to build open-data/ckanext-canada.

Build stages available:

- base: base CKAN only, built from CKAN open-data's fork on canada-v2.10 branch.
- ckanext: CKAN instance extended.

Types: base, registry, and public

Setup attempts to use sane default config values, but it should be tailored for
specific use using `envvars`.
