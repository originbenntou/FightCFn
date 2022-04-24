aws_profile=${AWS_PROFILE}
aws_region=ap-northeast-1

deploy-s3-%:
	aws cloudformation deploy \
		--stack-name s3-$* \
		--template-file ./S3/$*.yml \
		--capabilities CAPABILITY_IAM \
		--no-fail-on-empty-changeset \
		--profile ${aws_profile} \
		--region ${aws_region}

deploy-codecommit:
	aws cloudformation deploy \
		--stack-name codecommit \
		--template-file ./CodeCommit/codecommit.yml \
		--capabilities CAPABILITY_IAM \
		--no-fail-on-empty-changeset \
		--profile ${aws_profile} \
		--region ${aws_region}

deploy-ecs-%:
	aws cloudformation deploy \
		--stack-name ecs-$* \
		--template-file ./ECS/$*.yml \
		--capabilities CAPABILITY_IAM \
		--no-fail-on-empty-changeset \
		--profile ${aws_profile} \
		--region ${aws_region}

deploy-codepipeline:
	aws cloudformation deploy \
		--stack-name codepipeline \
		--template-file ./CodePipeline/codepipeline.yml \
		--capabilities CAPABILITY_IAM \
		--no-fail-on-empty-changeset \
		--profile ${aws_profile} \
		--region ${aws_region}

