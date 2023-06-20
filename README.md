# HiPS HSC-VISTA
This repository contains scripts for HiPS image generation for the HSC-VISTA coadds produced in [lsst-ir-fusion/dmu4](https://github.com/lsst-uk/lsst-ir-fusion/tree/master/dmu4), using the [LSST pipe_tasks package](https://github.com/lsst/pipe_tasks/tree/main). These scripts are based on the ones in available in [ci_hsc](https://github.com/lsst/ci_hsc_gen3). 

To generate HiPS images from the coadds, we need: a butler repository with the coadds, obs_vista, a version of lsst_stack that has the required tasks available, and .yaml files with the pipeline tasks definitions.

In this repo, ```/bin``` contains the scripts, ```/pipeline_tasks``` contains the pipeline tasks definitions ```notes.md``` contains instructions and notes on how to run things and ```test.html```is a simple test so see whether the generated HiPS can be visualized.
