#!/usr/bin/env bash
# 收集 Intel OpenVINO 加速包（Release 运行时，不含 PDB/Debug）。
# 用法: package.sh [--with-maacore <MaaCore.dll路径>] [--out <输出目录>]
set -euo pipefail

MD="$(cd "$(dirname "$0")/.." && pwd)"
RT="$MD/runtime/maa-x64-windows"
OUT="$MD/openvino-pack/dist"
MAACORE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --with-maacore) MAACORE="$2"; shift 2 ;;
        --out) OUT="$2"; shift 2 ;;
        *) echo "unknown arg: $1" >&2; exit 1 ;;
    esac
done

mkdir -p "$OUT"

copy_if_exists() {
    local pattern="$1"
    for f in $pattern; do
        [ -f "$f" ] && cp -f "$f" "$OUT/"
    done
}

# ONNX Runtime (OpenVINO EP)
copy_if_exists "$RT/onnxruntime_maa.dll"
copy_if_exists "$RT/onnxruntime_providers_openvino.dll"
copy_if_exists "$RT/onnxruntime_providers_shared.dll"

# OpenVINO runtime: core, CPU/NPU plugins, compiler, ONNX/IR frontends, TBB
copy_if_exists "$RT/openvino.dll"
copy_if_exists "$RT/openvino_intel_cpu_plugin.dll"
copy_if_exists "$RT/openvino_intel_npu_plugin.dll"
copy_if_exists "$RT/openvino_intel_npu_compiler.dll"
copy_if_exists "$RT/openvino_onnx_frontend*.dll"
copy_if_exists "$RT/openvino_ir_frontend*.dll"
copy_if_exists "$RT/tbb12*.dll"

# 可选：OpenVINO 构建的 MaaCore（启用原生 OCR）
if [[ -n "$MAACORE" ]]; then
    cp -f "$MAACORE" "$OUT/MaaCore.dll"
fi

cp -f "$(dirname "$0")/README.md" "$OUT/" 2>/dev/null || true
cp -f "$(dirname "$0")/install.ps1" "$OUT/" 2>/dev/null || true

echo "pack contents:"
ls -lh "$OUT"
echo "output: $OUT"
