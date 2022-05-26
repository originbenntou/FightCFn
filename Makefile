aws_profile:=${AWS_PROFILE}
aws_region?=ap-northeast-1

# TODO: 要変更
product_name?=myproduct
env?=dev

# awsデプロイのoption
ifeq ($(env), dev)
	# dev: ロールバックするとエラーログも消えるため自動ロールバックはオフ
	option:=--capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --no-fail-on-empty-changeset --disable-rollback
else
	# stg|prd: チェンジセットだけ出力してスタックに自動適用しない
	option:=--capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --no-execute-changeset
endif

# CFnのテンプレートバケット（CloudFormationでデプロイするときは必須）
template_bucket?=$(product_name)-template-$(env)

.PHONY: $(shell egrep -o ^[a-zA-Z_-]+: $(MAKEFILE_LIST) | sed 's/://')

# templateバケット作成専用（CloudFormationでデプロイするときは必須）
create_template_bucket:
	aws cloudformation deploy --profile $(aws_profile) --region $(aws_region) \
		--template-file ./stacks/other/create_template_bucket.yml \
		--stack-name $(product_name)-template-bucket-$(env) \
		--parameter-overrides ProductName=$(product_name) Env=$(env) BucketName=$(template_bucket)

# スタックデプロイ
deploy: set-mode set-target lint
	@echo "####### DEPLOY MODE: $(mode) #######"
ifeq ($(mode), rain)
	rain deploy -y --profile $(aws_profile) --region $(aws_region) \
		./stacks/$(target)/master.yml \
		$(product_name)-$(shell echo $(target) |  sed -e 's/\//-/g')-$(env) \
		--params $(shell cat $(shell pwd)/stacks/$(target)/parameter-$(env).json | jq -r -c '[.[] | .ParameterKey+"="+.ParameterValue ] | @csv')
else
	$(call _aws-package)
	$(call _aws-deploy)
endif

rm: set-mode set-target
	@echo "####### RM MODE: $(mode) #######"
ifeq ($(mode), rain)
	rain rm -y --profile $(aws_profile) --region $(aws_region) \
		$(product_name)-$(shell echo $(target) |  sed -e 's/\//-/g')-$(env)
else
	echo 'not implement'
endif

# CFn実行モード選択
set-mode:
	$(eval mode:=$(shell echo 'rain\ncloudformation' | peco))

# 実行スタック選択
set-target:
	$(eval target:=$(shell find stacks -type f -name master.yml | sed -e 's/stacks\///g' | sed -e 's/\/master.yml//g' | sort | peco))

# Linter
lint:
	cfn-lint --region $(aws_region) --template ./templates/*/*  --ignore-checks W

# aws package
define _aws-package
	aws cloudformation package --profile $(aws_profile) --region $(aws_region) \
		--template-file ./stacks/$(target)/master.yml \
		--output-template-file ./stacks/$(target)/package.yml \
		--s3-bucket $(template_bucket) \
		--s3-prefix $(target)
endef

# aws deploy
define _aws-deploy
	aws cloudformation deploy --profile $(aws_profile) --region $(aws_region) \
		--template-file ./stacks/$(target)/package.yml \
		--stack-name $(product_name)-$(shell echo $(target) |  sed -e 's/\//-/g')-$(env) \
		--parameter-overrides file://$(shell pwd)/stacks/$(target)/parameter-$(env).json \
		$(option)
endef

define _protect_stack
	echo 'not implement'
endef
