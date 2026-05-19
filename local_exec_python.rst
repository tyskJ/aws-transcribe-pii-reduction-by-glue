=====================================================================
*transcribe_json_to_excel.py* ローカル実行
=====================================================================

前提条件
=====================================================================
* 実作業は *modules/lambda/asset* フォルダで実施すること
* 以下コマンドを実行し、*admin* プロファイルを作成していること (デフォルトリージョンは *ap-northeast-1* )

.. code-block:: bash
  
  aws login --profile admin

.. code-block:: bash

  CONFIG="$HOME/.aws/config"
  
  PROFILES=(
    admin
  )
  
  for PROFILE in "${PROFILES[@]}"; do
    LINE="credential_process = aws configure export-credentials --profile ${PROFILE}"
  
    awk -v profile="$PROFILE" -v line="$LINE" '
    BEGIN {
      in_profile = 0
      found = 0
    }
  
    /^\[profile[[:space:]]+/ {
      # 対象 profile を抜ける直前に、未追加なら挿入
      if (in_profile && !found) {
        print line
      }
      in_profile = ($0 == "[profile " profile "]")
      found = 0
    }
  
    {
      if (in_profile && $0 ~ /^[[:space:]]*credential_process[[:space:]]*=/) {
        found = 1
      }
      print
    }
  
    END {
      # ファイル末尾が対象 profile の場合
      if (in_profile && !found) {
        print line
      }
    }
    ' "$CONFIG" > "$CONFIG.tmp" && command mv -f "$CONFIG.tmp" "$CONFIG"
  
  done

事前作業
=====================================================================
1. 各種モジュール準備
---------------------------------------------------------------------
.. code-block::

  pip install openpyxl -t vendor/

.. code-block::

  pip install boto3 -t vendor/

.. code-block::

  pip install awscrt -t vendor/

実作業 - ローカル -
=====================================================================
.. code-block::

  python transcribe_json_to_excel.py input.json output.xlsx