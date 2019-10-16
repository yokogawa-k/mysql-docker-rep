# vi: set ft=make ts=2 sw=2 sts=0 noet:

SHELL := /bin/bash

BINLOG_FORMATS  := row mixed statement
MYSQL_VERSIONS := 5.6 5.7 8 8.0

.PHONY: default
default: help

# http://postd.cc/auto-documented-makefile/
.PHONY: help help-common
help: help-common help-list-rep_versions help-list-rep_versions_and_format

help-common:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m %-30s\033[0m %s\n", $$1, $$2}'

.PHONY: up rep
up: ## 最新の MySQL イメージでレプリケーション環境を構築
	docker-compose up -d

rep: up ## up へのエイリアス

exec-master: ## master にログイン
	docker-compose exec master bash

exec: exec-master ## exec-master のエイリアス

exec-slave: ## slave にログイン
	docker-compose exec slave bash

down: ## docker-compose down
	docker-compose down

define rep_version_template
.PHONY: rep-$(1)
all-rep: rep-$(1)

rep-$(1):
	@make IMAGE=mysql:$(1) rep

help-list-rep_version-$(1):
	@printf "\033[36m %-30s\033[0m %s\n" "rep-$1" "MySQL $1 のイメージを利用してレプリケーションを構築"

help-list-rep_versions: help-list-rep_version-$(1)

endef

$(foreach _version,$(MYSQL_VERSIONS),$(eval $(call rep_version_template,$(_version)))): ## 指定した MySQL バージョンでレプリケーション構成を構築する

define rep_version_format_template
.PHONY: rep-$(1)-$(2)

rep-$(1)-$(2):
	@make IMAGE=mysql:$(1) BINLOG_FORMAT=$(2) rep

help-list-rep_version_and_format-$(1)-$(2):
	@printf "\033[36m %-30s\033[0m %s\n" "rep-$1-$2" "MySQL $1 のイメージを利用して $2 の binlog_format でレプリケーションを構築"

help-list-rep_versions_and_format: help-list-rep_version_and_format-$(1)-$(2)

endef

$(foreach _version,$(MYSQL_VERSIONS),$(foreach _format,$(BINLOG_FORMATS),$(eval $(call rep_version_format_template,$(_version),$(_format))))): ## 指定した MySQL バージョンと binlog_format でレプリケーション構成を構築する

# https://github.com/Respect/samples/blob/master/Makefile#L295
# Re-usable target for yes no prompt. Usage: make .prompt-yesno message="Is it yes or no?"
# Will exit with error if not yes
.PHONY: .prompt-yesno
.prompt-yesno:
	@exec 9<&0 0</dev/tty; \
	echo "$(message) [y/N]:"; \
	read -r -t 60 -n 3 yn; \
	exec 0<&9 9<&-; \
	if [[ -z $$yn ]]; then \
		echo "Please input y(es) or n(o)."; \
		exit 1; \
	else \
		if [[ $$yn =~ ^[yY] ]]; then \
			echo "continue" >&2; \
		else \
			echo "abort." >&2; \
			exit 1; \
		fi; \
	fi
