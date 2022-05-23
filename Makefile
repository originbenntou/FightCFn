.PHONY: $(shell egrep -o ^[a-zA-Z_-]+: $(MAKEFILE_LIST) | sed 's/://')

aws_profile:=${AWS_PROFILE}
aws_region?=ap-northeast-1

# TODO: 要変更
product_name?=myproduct
env?=dev

frontend_repo?=$(product_name)-frontend
backend_repo?=$(product_name)-backend
infra_repo?=$(product_name)-infra

# TODO: 要変更
frontend_image?=
backend_image?=

template_bucket?=template-$(product_name)-$(env)

target?=

cmd: validate
	echo $(target)

validate:
	ifndef $(target)
		$(error target is not set)
	else
		$(error aaaaaa is not set)
	endif

package:
	$(call _cfn_validate,$target)
	@echo "\n"
	$(call _cfn_package,$target)

deploy:
	$(call _cfn_deploy,$*)

define _cfn_validate
	aws cloudformation validate-template \
		--template-body file://$(shell pwd)/stacks/$1/master.yml \
		--output text \
		--profile $(aws_profile) \
		--region $(aws_region)
endef

define _cfn_package
	aws cloudformation package \
		--template-file ./stacks/$1/master.yml \
		--s3-bucket $(cfn_template_bucket) \
		--s3-prefix $1\
		--output-template-file ./stacks/$1/package.yml \
		--profile $(aws_profile) \
		--region $(aws_region)
endef

# FIXME: disable-rollbackを外す、no-execute-changesetをつける、parameter-overrideをやめる
define _cfn_deploy
	aws cloudformation deploy \
		--template-file ./stacks/$(shell echo $1 |  sed -e 's/-/\//g')/package.yml \
		--parameter-overrides ProductName=$(product_name) Env=$(env) \
		--stack-name $(product_name)-$1-$(env) \
		--capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
		--no-fail-on-empty-changeset \
		--disable-rolleback \
		--profile $(aws_profile) \
		--region $(aws_region)
endef

create_template_bucket:
	aws cloudformation deploy \
		--template-file ./template_bucket.yml \
		--parameter-overrides ProductName=$(product_name) Env=$(env) BucketName=$(cfn_template_bucket) \
		--stack-name $(product_name)-cfn-template-bucket-$(env) \
		--no-fail-on-empty-changeset \
		--profile $(aws_profile) \
		--region $(aws_region)
