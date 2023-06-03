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

import:
	python-lambda-local src/tagdb.py event.json -f handler -l src

reset:
	rm ./docker/dynamodb/*.db
