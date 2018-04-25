# -*- mode: makefile; tab-width: 8; indent-tabs-mode: 1 -*-
# vim: ts=8 sw=8 ft=make noet

VERSIONS=2.6 3.0 3.2 3.4
SERVICE=mongodb

default: all

.PHONY: all

all: stable

.PHONY: test

test: $(addprefix test-,${VERSIONS})

.PHONY: test-%

test-%: nanobox/${SERVICE}-%
	stdbuf -oL test/run_all.sh $(subst test-,,$@)

.PHONY: nanobox/${SERVICE}-%

nanobox/${SERVICE}-%:
	docker pull $(subst -,:,$@) || (docker pull $(subst -,:,$@)-beta; docker tag $(subst -,:,$@)-beta $(subst -,:,$@))

.PHONY: stable beta alpha

stable:
	@./util/publish.sh stable

beta:
	@./util/publish.sh beta

alpha:
	@./util/publish.sh alpha