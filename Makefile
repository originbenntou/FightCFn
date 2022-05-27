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

# CFn実行モード選択
mode:=$(shell echo 'rain\ncloudformation' | peco)
ifndef mode
	$(error mode is not set)
endif

# 実行スタック選択
target:=$(shell find stacks -type f -name master.yml | sed -e 's/stacks\///g' | sed -e 's/\/master.yml//g' | sort | peco)
ifndef target
	$(error target is not set)
endif


.PHONY: $(shell egrep -o ^[a-zA-Z_-]+: $(MAKEFILE_LIST) | sed 's/://')

# Linter起動
lint:
	cfn-lint --region $(aws_region) --template ./templates/*/*  --ignore-checks W

# スタックデプロイ
deploy: lint
	@echo "####### DEPLOY MODE: $(mode) #######"
ifeq ($(mode), rain)
	rain deploy -y --profile $(aws_profile) --region $(aws_region) \
		./stacks/$(target)/master.yml \
		$(product_name)-$(shell echo $(target) |  sed -e 's/\//-/g')-$(env) \
		--params $(shell cat $(shell pwd)/stacks/$(target)/parameter-$(env).json | jq -r -c '[.[] | .ParameterKey+"="+.ParameterValue ] | @csv')
else
	$(call _aws-package)
	@echo "\n"
	$(call _aws-deploy)
endif

# スタック削除
rm:
	@echo "####### RM MODE: $(mode) #######"
ifeq ($(mode), rain)
	rain rm -y --profile $(aws_profile) --region $(aws_region) \
		$(product_name)-$(shell echo $(target) |  sed -e 's/\//-/g')-$(env)
else
	@echo 'not implement'
endif

# スタック保護
protect-stack:
	echo 'not implement'

# aws package
define _aws-package
	$(eval template_bucket_name:=$(product_name)-cfn-templateaabaaaaaaabaaaaa-$(env))

	$(eval exist:=$(shell aws s3api head-bucket --profile $(aws_profile) --region $(aws_region) \
		--bucket $(template_bucket_name) 2>&1 | grep -cE '404'))
	@if [ $(exist) -eq 1 ]; then \
		echo "cfn template bucket is not exist. creating...."; \
		$(call _create-template-bucket,$(template_bucket_name)); \
		echo "\n"; \
	fi

	@echo "####### UPLOAD TEMPLATE & PACKAGE STACK #######"

	aws cloudformation package --profile $(aws_profile) --region $(aws_region) \
		--template-file ./stacks/$(target)/master.yml \
		--output-template-file ./stacks/$(target)/package.yml \
		--s3-bucket $(template_bucket_name) \
		--s3-prefix $(target)
endef

# aws deploy
define _aws-deploy
	@echo "####### DEPLOY STACK #######"

	aws cloudformation deploy --profile $(aws_profile) --region $(aws_region) \
		--template-file ./stacks/$(target)/package.yml \
		--stack-name $(product_name)-$(shell echo $(target) |  sed -e 's/\//-/g')-$(env) \
		--parameter-overrides file://$(shell pwd)/stacks/$(target)/parameter-$(env).json \
		$(option)
endef

# CFnテンプレートバケット作成（cloudformationデプロイで必須）
define _create-template-bucket
	aws cloudformation deploy --profile $(aws_profile) --region $(aws_region) \
		--template-file ./stacks/other/create_template_bucket.yml \
		--stack-name $1 \
		--parameter-overrides ProductName=$(product_name) Env=$(env) BucketName=$1
endef

# 本プロダクトのECRレジストリ作成
define _create-ecr-registry
	echo 'not implement'
endef

# 本プロダクトのCodeCommintリポジトリ作成
define _create-codecommit-repository
	echo 'not implement'
endef
