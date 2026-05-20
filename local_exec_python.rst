=====================================================================
*transcribe_json_to_excel.py* ローカル実行
=====================================================================

前提条件
=====================================================================
* 実作業は *modules/lambda/asset* フォルダで実施すること
* 以下コマンドを実行し、*admin* プロファイルを作成していること (デフォルトリージョンは *ap-northeast-1* )

.. code-block:: bash
  
  aws login --profile admin

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