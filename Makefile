aws_profile:=${AWS_PROFILE}
aws_region?=ap-northeast-1

# TODO: 要変更
product_name?=myproduct
env?=dev

template_bucket?=$(product_name)-template-$(env)

.PHONY: $(shell egrep -o ^[a-zA-Z_-]+: $(MAKEFILE_LIST) | sed 's/://')

all: package deploy

package: target-check _lint_cfn _validate_cfn
	aws cloudformation package --profile $(aws_profile) --region $(aws_region) \
		--template-file ./stacks/$(target)/master.yml \
		--output-template-file ./stacks/$(target)/package.yml \
		--s3-bucket $(template_bucket) \
		--s3-prefix $(target)

#deploy: target-check set-deploy-option
#	aws cloudformation deploy --profile $(aws_profile) --region $(aws_region) \
#		--template-file ./stacks/$(target)/package.yml \
#		--stack-name $(product_name)-$(shell echo $(target) |  sed -e 's/\//-/g')-$(env) \
#		--parameter-overrides file://$(shell pwd)/stacks/$(target)/parameter-$(env).json
#		$(option)

deploy: target-check
	rain deploy -y --profile $(aws_profile) \
		./stacks/$(target)/package.yml \
		$(product_name)-$(shell echo $(target) |  sed -e 's/\//-/g')-$(env) \
		--params $(shell cat $(shell pwd)/stacks/$(target)/parameter-$(env).json | jq -r -c '[.[] | .ParameterKey+"="+.ParameterValue ] | @csv')

rm: target-check
	rain rm -y --profile $(aws_profile) \
		$(product_name)-$(shell echo $(target) |  sed -e 's/\//-/g')-$(env)

# templateバケット作成専用
create_template_bucket:
	aws cloudformation deploy --profile $(aws_profile) --region $(aws_region) \
		--template-file ./stacks/other/create_template_bucket.yml \
		--stack-name $(product_name)-template-bucket-$(env) \
		--parameter-overrides ProductName=$(product_name) Env=$(env) BucketName=$(template_bucket)

# 実行ファイル指定確認
target-check:
ifndef target
	$(error target is not set)
endif

# 環境ごとにデプロイオプション変更
## dev: ロールバックするとエラーログも消えるため自動ロールバックはオフ
## stg,prd: チェンジセットだけ出力してスタックに自動適用しない
set-deploy-option:
ifeq ($(env),dev)
option=--capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
	--no-fail-on-empty-changeset \
	--disable-rollback
else
option=--capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
	--no-execute-changeset
endif

# CFn標準バリデーション
_validate_cfn:
	aws cloudformation validate-template --profile $(aws_profile) --region $(aws_region) \
		--template-body file://$(shell pwd)/stacks/$(target)/master.yml \
		--output text

# CFn Linter
## pip3 install cfn-lint
_lint_cfn:
	cfn-lint --region $(aws_region) --template ./templates/*/*  --ignore-checks W

# スタック保護
