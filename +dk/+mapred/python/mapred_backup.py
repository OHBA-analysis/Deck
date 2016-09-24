#!/usr/bin/env python

import os
import argparse
import mapred_utils as util

if __name__ == '__main__':

    parser = argparse.ArgumentParser( prog='mapres_backup' )
    parser.add_argument('name', help='Name of the subfolder to create in the data directory')
    parser.add_argument('--config', default='', help='Configuration file (will be searched if omitted)')
    args = parser.parse_args()

    # Get config file and read it
    cfgfile = args.config
    if not cfgfile:
        cfgfile = util.find_config()

    config = util.read_json(cfgfile)
    folder = os.getcwd()

    # Create subfolder
    subfolder = os.path.join( folder, 'data', args.name )
    assert not os.path.isdir(subfolder), 'Folder "%s" already exists, aborting.' % (subfolder)
    os.makedirs( subfolder )

    # Move any worker output there
    nworkers = len(config['exec']['workers'])
    moved = []
    for i in xrange(nworkers):
        workername = config['files']['worker'] % (i+1)
        workerfile = os.path.join( folder, workername )
        if os.path.isfile(workerfile):
            moved.append(workerfile)
            os.rename( workerfile, os.path.join(subfolder,workername) )

    # Write summary
    print 'Moved %d files to folder "%s":' % ( len(moved), subfolder )
    for f in moved:
        print "\t" + f
