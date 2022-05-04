aws_profile:=${AWS_PROFILE}
aws_region?=ap-northeast-1

# TODO: 要変更
product_name?=myproduct
env?=dev
pwd=$(shell pwd)

cfn_template_bucket?=cfn-template-$(product_name)-$(env)

.PHONY: package-% deploy-% create_cfn_template_bucket

package-%:
	$(call _cfn_validate,$*)
	@echo "\n"
	$(call _cfn_package,$*)

deploy-%:
	$(call _cfn_deploy,$*)

define _cfn_validate
	aws cloudformation validate-template \
		--template-body file://$(pwd)/stacks/$1/master.yml \
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

define _cfn_deploy
	aws cloudformation deploy \
		--template-file ./stacks/$1/package.yml \
		--parameter-overrides ProductName=$(product_name) Env=$(env) \
		--stack-name $(product_name)-$1-$(env) \
		--capabilities CAPABILITY_NAMED_IAM \
		--no-fail-on-empty-changeset \
		--profile $(aws_profile) \
		--region $(aws_region)
endef

create_cfn_template_bucket:
	aws cloudformation deploy \
		--template-file ./template_bucket.yml \
		--parameter-overrides ProductName=$(product_name) Env=$(env) BucketName=$(cfn_template_bucket) \
		--stack-name $(product_name)-cfn-template-bucket-$(env) \
		--no-fail-on-empty-changeset \
		--profile $(aws_profile) \
		--region $(aws_region)
