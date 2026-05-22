# フォルダ構成

- フォルダ構成は以下の通り

```
.
├── envs
│   ├── backend.tf                                                tfstateファイル管理定義ファイル
│   ├── config
│   │   └── steps.json                                            Glue DataBrew Recipe フロー定義ファイル
│   ├── data.tf                                                   外部データソース定義ファイル
│   ├── locals.tf                                                 ローカル変数定義ファイル
│   ├── main.tf                                                   デプロイリソース定義ファイル
│   ├── outputs.tf                                                リソース戻り値定義ファイル
│   ├── providers.tf                                              プロバイダー定義ファイル
│   ├── variables.tf                                              変数定義ファイル
│   └── versions.tf                                               Terraformバージョン定義ファイル
└── modules
    ├── cloudwatch                                                Amazon CloudWatch
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── eventbridge                                               Amazon EventBridge
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── iam_role                                                  AWS IAM Role
    │   ├── custom_policy.tf                                        カスタムポリシー定義ファイル
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── lambda                                                    AWS Lambda
    │   ├── asset
    │   │   ├── create_include_pii_wav.py                           WAVファイル作成用
    │   │   ├── glue_csv_to_text.py                                 Glue DataBrew 出力ファイル整形用
    │   │   └── transcribe_json_to_excel.py                         Transcribe 出力ファイル整形用
    │   ├── data.tf
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── scripts
    │   │   ├── layer_library_create.sh                             Lambda Layer 用パッケージ取得スクリプト
    │   │   └── requirements.txt                                    パッケージ定義ファイル
    │   └── variables.tf
    ├── s3                                                        Amazon S3
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    └── step_functions                                            AWS Step Functions
        ├── config
        │   └── transcribe-glue-databrew-state-machine.asl.json     ステートマシン定義ファイル
        ├── main.tf
        ├── outputs.tf
        └── variables.tf
```
