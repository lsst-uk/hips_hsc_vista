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

jobs=$4
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
COLLECTION=$2
HIPS_COLLECTION=$3
echo "Working on repo  : $repo"
echo "Input collection : $COLLECTION"
echo "Hips collection  : $HIPS_COLLECTION"
echo "Number of jobs   : $jobs"
HIPS_QGRAPH_FILE="$repo"/"$HIPS_COLLECTION"/hips.qgraph
echo "$HIPS_QGRAPH_FILE"


#echo 'Generating quantum graph: segment'

#build-high-resolution-hips-qg segment -b "$repo" -p "../pipeline_tasks/highres_hips.yaml" -i "$COLLECTION"

echo 'Generating quantum graph: build'

#build-high-resolution-hips-qg build \
#    -b "$repo" -p "../pipeline_tasks/highres_hips.yaml" \
#    -i "$COLLECTION" -q "$HIPS_QGRAPH_FILE" \
#    -P 17
    
echo 'wrapping coadds '
start_time=$(date +%s)

pipetask --long-log --log-level="$loglevel" run \
    -j "$jobs" -b "$repo" \
    --output-run "$HIPS_COLLECTION" \
    --register-dataset-types \
    --extend-run \
    -g "$HIPS_QGRAPH_FILE"

end_time=$(date +%s)
echo "Time it took to wrap coadds: $elapsed_time seconds"

# echo 'generating hips'

# pipetask --long-log --log-level="$loglevel" run \
#     -j "$jobs" -b "$repo"/butler.yaml \
#     -i "$HIPS_COLLECTION" \
#     --output "$HIPS_COLLECTION" \
#     -p "../pipeline_tasks/gen_hips.yaml" \
#     -c "generateHips:hips_base_uri=$repo/hips" \
#     --register-dataset-types $mock
