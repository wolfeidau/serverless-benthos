# serverless-benthos

This serverless application provides enables deployment of [benthos](https://github.com/Jeffail/benthos) to [AWS Lambda](https://aws.amazon.com/lambda/) using the [Serverless Application Repository](https://aws.amazon.com/serverless/serverlessrepo/). This removes the need to manage uploads to [S3](https://aws.amazon.com/s3/) for deployment of benthos using [cloudformation](https://aws.amazon.com/cloudformation/) which makes it easier to use this engine throughout your applications.

# Usage

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: 'AWS::Serverless-2016-10-31'
Description: >-
  This template demonstrates how to use the serverless-benthos application.

Parameters:
  BenthosConfig:
    Type: String
    Description: >
      A YAML configuration for the Benthos pipeline, can include any traditional
      sections except for input or buffer.
    Default: |
      pipeline:
        processors:
        - type: metadata
          metadata:
            operator: set
            key: AWS_LAMBDA_FUNCTION_VERSION
            value: "${AWS_LAMBDA_FUNCTION_VERSION}"

Resources:
  ServerlessBenthos:
    Type: 'AWS::Serverless::Application'
    Properties:
      Location:
        ApplicationId: arn:aws:serverlessrepo:us-east-1:170889777468:applications/serverless-benthos
        SemanticVersion: 3.54.1
      Parameters:
        BenthosConfig: !Ref BenthosConfig

Outputs:
  BenthosFunctionArn:
    Description: "Benthos Lambda Function ARN"
    Value: !GetAtt ServerlessBenthos.Outputs.FunctionArn
```

# License

This application is released under MIT license and is copyright Mark Wolfe.