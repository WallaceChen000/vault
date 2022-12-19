PWD := $(shell pwd)
args = `arg="$(filter-out $@,$(MAKECMDGOALS))" && echo $${arg:-${1}}`

.PHONY: clean
all: buildimg

action:
	@echo $(call args,defaultstring)

buildimg:
	docker build -t infortrend/sriov-test:A01 . --no-cache -f Dockerfile
push:
	docker push infortrend/sriov-test:A01
clean:
	#rm -f ./bin/*

