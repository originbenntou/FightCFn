AWS_PROFILE:=${AWS_PROFILE}
AWS_REGION:=ap-northeast-1

project_name:=fight
env:=test

deploy:


define _cfn_deploy
	aws cloudformation deploy \
		--stack-name $1 \
		--template-file $2 \
		--capabilities CAPABILITY_NAMED_IAM \
		--no-fail-on-empty-changeset \
		--profile ${AWS_PROFILE} \
		--region ${AWS_REGION}
endef

deploy-s3-%:
	aws cloudformation deploy \
		--stack-name s3-$* \
		--template-file ./S3/$*.yml \
		--capabilities CAPABILITY_NAMED_IAM \
		--no-fail-on-empty-changeset \
		--profile ${aws_profile} \
		--region ${aws_region}

deploy-codecommit:
	aws cloudformation deploy \
		--stack-name codecommit \
		--template-file ./CodeCommit/codecommit.yml \
		--capabilities CAPABILITY_NAMED_IAM \
		--no-fail-on-empty-changeset \
		--profile ${aws_profile} \
		--region ${aws_region}

deploy-network:
	aws cloudformation deploy \
		--stack-name ecs-$* \
		--template-file ./ECS/$*.yml \
		--capabilities CAPABILITY_NAMED_IAM \
		--no-fail-on-empty-changeset \
		--profile ${aws_profile} \
		--region ${aws_region}

deploy-ecs-%:
	aws cloudformation deploy \
		--stack-name ecs-$* \
		--template-file ./ECS/$*.yml \
		--capabilities CAPABILITY_NAMED_IAM \
		--no-fail-on-empty-changeset \
		--profile ${aws_profile} \
		--region ${aws_region}

deploy-codepipeline:
	aws cloudformation deploy \
		--stack-name codepipeline \
		--template-file ./CodePipeline/codepipeline.yml \
		--capabilities CAPABILITY_NAMED_IAM \
		--no-fail-on-empty-changeset \
		--profile ${aws_profile} \
		--region ${aws_region}

