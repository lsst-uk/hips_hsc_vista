import lsst.daf.butler as dafButler 
import time

REPO="../demo_data"
butler = dafButler.Butler(REPO,writeable=True)
butler.import_(
    directory='..',
    filename='../demo_data/demo_export_tiny.yaml'
)


