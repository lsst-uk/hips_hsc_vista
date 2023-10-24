# Notes

The HSC-VISTA coadds are handled with the [obs_vista](https://github.com/lsst-uk/obs_vista) package. To install the package, the repository needs to be cloned under the lsst_stack directory where all other applications are stored. This will be something like $EUPS_PATH/Linux64/. The package then needs to be delcared and setup. 

```
cd $EUPS_PATH/Linux64/ #or something other than Linux64 depending on the OS
mkdir obs_vista
cd obs_vista
git clone https://github.com/lsst-uk/obs_vista
mv obs_vista 22.0.0-1
eups declare -t current obs_vista 22.0.0-1
setup obs_vista #this needs to be set up in every terminal
```
obs_vista contains a directory 'python/lsstuk' where the code is, unline other lsst_stack apps, where the code is under 'python/lsst'. For obs_vista to work with pipeline_tasks, that directory needs to be renamed to 'python/lsst'.

```
mv $EUPS_PATH/Linux64/obs_vista/22.0.0-1/python/lsstuk $EUPS_PATH/Linux64/obs_vista/22.0.0-1/python/lsst
```
Once obs_vista has been correctly set up, in the butler root directory for our data, we can register the VIRCAM instrument.

```
butler register-instrument $BUTLER_REPO lsst.obs.vista.VIRCAM 
```

HiPS images are generated using pipeline_tasks, specifically HighResolutionHipsTask and GenerateHipsTask. GenerateHipsTask and GenerateColorHipsTask are only available in the latest
stack versions (not the stable 24.0.0 version). I used the version tagged w2023_21, which can be installed from scracth or updated using eups.

To run these tasks, they need to be defined in .yaml files. In this repository, these files are in ```/pipeline_tasks```. In both, we need to specify:
```instrument: lsst.obs.vista.VIRCAM```

The process involves several steps:

First, a custom quantum graph needs to be generated. This is done in two steps: by segementing the survey and then actually building the quantum graph. Apparently pipeline_tasks are not usually allowed to write files outside of the Butler,
but this case is an exception. More detailed docimentation can be found in

```
build-high-resolution-hips-qg segment -b "$BUTLER_REPO" -p "$PATH_TO_PIPELINE_TASKS/highres_hips.yaml" -i "$COLLECTION" #survey segmentation

build-high-resolution-hips-qg build \ #quantum graph creation
    -b "$BUTLER_REPO" -p "$PATH_TO_PIPELINE_TASKS/highres_hips.yaml" \
    -i "$COLLECTION"\
    --pixels 17 -q "$HIPS_QGRAPH_FILE" #number of pixels is printed in previous step.
```
The coadds then need to be warpped to HEALPix grid:
```
pipetask --long-log --log-level="$loglevel" run \
    -j "$jobs" -b "$BUTLER_REPO"/butler.yaml \
    --output "$HIPS_COLLECTION" \
    --register-dataset-types $mock \
    -g "$HIPS_QGRAPH_FILE" #the file generated in the previous step
```
Finally, we can generate the HiPS tree:
```
pipetask --long-log --log-level="$loglevel" run \
    -j "$jobs" -b "$BUTLER_REPO"/butler.yaml \
    -i "$HIPS_COLLECTION" \
    --output "$HIPS_COLLECTION" \
    -p "$PATH_TO_PIPELINE_TASKS/gen_hips.yaml" \
    -c "generateHips:hips_base_uri=$BUTLER_REPO/hips" \
    --register-dataset-types $mock
```
This final step, however, gives an exception: 'No way to apply find_first to .. with required engine 'sql': find_first does not commute with anything'.
This can be bypassed by adding: find_first=False in find_dataset in _query.py in $EUPS_PATH/Linux64/daf_butler/$stack_version/python/lsst/daf/butler/regestry/queries/. 
This is obviously not an ideal solution, but I have yet to figure out how this can be fixed.

To check that the HiPS images were generated correctly, we can visualize them using ```test.html```. Simply start a python server:
```
python3 -m http.server
```
And then access the visualization in your browser at ```http://0.0.0.0:8000/test.html```
