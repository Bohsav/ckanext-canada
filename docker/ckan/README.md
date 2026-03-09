# (WIP) README

**Important note**: the extension uses Bohsav's fork for ckanext-canada on
dockerfile branch (this branch), where it always assumes that the site is
registry. **To override this behaviour**: change line 170 of Dockerfile to point
to the open-data/ckanext-canada.git@master.

## Overview

Dockerfile to build Bohsav/ckanext-canada (compatible with
open-data/ckanext-canada, see note above). Please note that the built
application has not been rigorously tested, so it could fail.

Build stages:

- base: base CKAN only, built using the same Dockerfile from ckan-docker-base
  Dockerfile.py3 for CKAN 2.10; however, the base is replaced with CKAN
  open-data's fork on canada-v2.10 branch.
- ckanext: CKAN instance extended with ckanext-canada.

## Dockerfile Arguments

CKAN_TYPE: registry and public (for both views of ckanext-canada)

## Notable Additions

This Dockerfile could be used to use CKAN workers by setting
`CKAN_WORKER="true"` environment variable.

## TODO

Create better behaviour between public or registry.
