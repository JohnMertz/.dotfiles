#!/bin/bash

# Prefer locally defined version
PLENV_VERSION=$(plenv local)
# Fall back to global version
if [[ -z $PLENV_VERSION ]]; then
    PLENV_VERSION=$(plenv global)
fi
# Finally fall back to installed version
if [[ -z $PLENV_VERSION ]]; then
    PLENV_VERSION=$(perl --version | grep 'version' | sed -r 's/.*\(v(5.[0-9][0-9].[0-9])\).*/\1/')
fi
export PLENV_VERSION

# Clear and re-assign Libraries using PLENV_VERSION
PERL5LIB=''
PERL5LIB=$(perl -e 'print join ":",@INC')
export PERL5LIB;
