#!/usr/bin/env sh

set -e


usage() {
    cat <<USAGE
Usage: $0 [-j N] [-m] [-l level] repo

Options:
    -h          Print usage information.
    -j N        Run pipetask with N processes, default is 1.
    -m          Run mock pipeline.
    -l level    Logging level, default is INFO.
USAGE
}

jobs=1
mock=
loglevel=INFO

while getopts hj:ml: opt
do
    case $opt in
        h) usage; exit;;
        j) jobs=$OPTARG;;
        m) mock="--mock";;
        l) loglevel=$OPTARG;;
        \?) usage 1>&2; exit 1;;
    esac
done
shift $((OPTIND - 1))
if [ $# -eq 0 ]; then
    usage 1>&2
    exit 1
fi
repo=$1

COLLECTION=demo_data
HIPS_COLLECTION=../demo_data/hips
HIPS_QGRAPH_FILE=../demo_data/hips/demo_hips.qgraph


echo 'generating quantum graph'

build-high-resolution-hips-qg segment -b "$repo" -p "../demo_data/pipeline_tasks/highres_hips.yaml" -i "$COLLECTION"

echo 'generating quantum graph'

build-high-resolution-hips-qg build \
    -b "$repo" -p "../demo_data/pipeline_tasks/highres_hips.yaml" \
    -i "$COLLECTION" -q "$HIPS_QGRAPH_FILE" \
    -P 17 --output "$HIPS_COLLECTION" \

echo 'wrapping coadds '

pipetask --long-log --log-level="$loglevel" run \
    -j "$jobs" -b "$repo"/butler.yaml \
    --output "$HIPS_COLLECTION" \
    --register-dataset-types $mock \
    -g "$HIPS_QGRAPH_FILE"

echo 'generating hips'

pipetask --long-log --log-level="$loglevel" run \
    -j "$jobs" -b "$repo"/butler.yaml \
    -i "$HIPS_COLLECTION" \
    --output "$HIPS_COLLECTION" \
    -p "../demo_data/pipeline_tasks/gen_hips.yaml" \
    -c "generateHips:hips_base_uri=$repo/hips" \
    -c "generateColorHips:hips_base_uri=$repo/hips" \
    --register-dataset-types $mock