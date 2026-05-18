#!/usr/bin/env bash

# Shell Options
# e : エラーがあったら直ちにシェルを終了
# u : 未定義変数を使用したときにエラーとする
# o : シェルオプションを有効にする
# pipefail : パイプラインの返り値を最後のエラー終了値にする (エラー終了値がない場合は0を返す)
set -euo pipefail

# echo to stderr
eecho() { echo "$@" 1>&2; }

usage() {
  cat <<EOF
Usage:
  $(basename "$0") <python-version>
Description:
  Create lambda layer zip file according to the requirements file.
Requirements:
  jq
Arguments:
  python-version    : Python version Ex. 3.14
EOF
}

# Check number of arguments
if [[ $# != 1 ]]; then
  usage && exit 1
fi

PYTHON_VERSION=$1

# このスクリプト自身のディレクトリ
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# SCRIPT_DIR の1つ上
BASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# build ディレクトリ
BUILD_DIR="${BASE_DIR}/build"

if [ -d "${BUILD_DIR}" ]; then
  rm -rf "${BUILD_DIR}"
fi

# Recreate build directory
mkdir -p "${BUILD_DIR}/layer"

# Get Package
# source配布を禁止しwheelのみ許可
# Lambda(Amazon Linux)向けLinux x86_64 wheelを取得
# インストール先ディレクトリ
# Python 3.14向けpackageを取得

pip install -q \
  --platform manylinux2014_x86_64 \
  --target="${BUILD_DIR}/layer/python/" \
  --implementation cp \
  --python-version ${PYTHON_VERSION} \
  --only-binary=:all: \
  --upgrade \
  -r "${SCRIPT_DIR}/requirements.txt"

# Remove pycache in build directory
find "${BUILD_DIR}" \
  \( -name "__pycache__" -o -name "*.pyc" -o -name "*.pyo" \) \
  -delete

# PWD=$(pwd)

# Return JSON for Terraform
# jq -n --arg path "${PWD}" '{"path":$path}'