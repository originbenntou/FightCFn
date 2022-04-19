aws_profile=${AWS_PROFILE}
aws_region=ap-northeast-1

deploy-ecs-%:
	aws cloudformation deploy \
		--stack-name ecs-$* \
		--template-file ./ECS/$*.yaml \
		--capabilities CAPABILITY_IAM \
		--no-fail-on-empty-changeset \
		--profile ${aws_profile} \
		--region ${aws_region}

deploy-code-pipeline:
	aws cloudformation deploy \
		--stack-name codepipeline \
		--template-file ./CodePipeline/codepipeline.yaml \
		--capabilities CAPABILITY_IAM \
		--no-fail-on-empty-changeset \
		--profile ${aws_profile} \
		--region ${aws_region}

