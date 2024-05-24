PROJECT = terraform-aws-ecs-tagdb
FUNCTION = $(PROJECT)

all: build

.PHONY: build import install scan setup

build:
	rm -f src/*.zip
	cd src; zip -X -r $(FUNCTION).zip . -x "*__pycache__*"
	cp src/$(FUNCTION).zip build/
	rm src/*.zip

import:
	@AWS_PROFILE=$(service) sam local invoke TagDBFunction --docker-network lambda-local \
		--event events/$(service).json

install:
	@rbenv install -s
	@gem install overcommit && overcommit --install && overcommit --sign pre-commit
	@docker network create lambda-local || true

scan:
	@AWS_ACCESS_KEY_ID=dummy AWS_SECRET_ACCESS_KEY=dummy  \
		aws dynamodb scan --table-name tagdb --endpoint-url http://localhost:8000

setup:
	@./create_db.sh
