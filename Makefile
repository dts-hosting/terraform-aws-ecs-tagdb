PROJECT = terraform-aws-ecs-tagdb
FUNCTION = $(PROJECT)

all: build

.PHONY: build clean import reset

build: clean
	cd src; pip install -r requirements.txt -t ./
	cd src; zip -X -r $(FUNCTION).zip . -x "*__pycache__*"
	cp src/$(FUNCTION).zip build/
	rm src/$(FUNCTION).zip

clean:
	rm -rf build/*
	rm -rf src/*/
	rm src/six.py

import:
	python-lambda-local src/tagdb.py event.json -f handler -l src

.PHONY: install
install:
	@rbenv install -s
	@gem install overcommit && overcommit --install && overcommit --sign pre-commit

reset:
	rm ./docker/dynamodb/*.db
