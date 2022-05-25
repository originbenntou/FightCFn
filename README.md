# Fight-CFn

CloudFormationで ECS on Fargate 環境を構築
AWSコンテナ設計・構築「本格」入門 参考

## IPv4 CIDRブロック設定

| NW区分    | AZ  | CIDR          | 用途      |
|---------|-----|---------------|---------|
| Public  | A   | 10.0.0.0/24   | Ingress |
| Public  | C   | 10.0.1.0/24   | Ingress |
| Private | A   | 10.0.8.0/24   | ECSTask |
| Private | C   | 10.0.9.0/24   | ECSTask |
| Private | A   | 10.0.16.0/24  | DB      |
| Private | C   | 10.0.17.0/24  | DB      |
| Public  | A   | 10.0.240.0/24 | Bastion |
| Public  | C   | 10.0.241.0/24 | Bastion |

## コマンド例

```
make all target=backend/030-application/010-share env=dev
```
