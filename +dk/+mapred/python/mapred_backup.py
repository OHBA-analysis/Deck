#!/usr/bin/env python

import os
import glob
import shutil
import tarfile
import argparse
import mapred_utils as util

if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('name', help='Name of the subfolder to create in the data directory')
    parser.add_argument('--jobs', action='store_true', help='Compress and bacup job folders')
    parser.add_argument('--config', default='', help='Configuration file (will be searched if omitted)')
    args = parser.parse_args()

    # Find config file
    cfgFile = args.config
    if not cfgFile:
        cfgFile = util.find_config()

    config = util.read_json(cfgFile)
    saveFolder = config['folders']['save']

    # Create backup folder
    backupFolder = os.path.join( saveFolder, 'data', args.name )
    assert not os.path.isdir(backupFolder), 'Folder "%s" already exists, aborting.' % (backupFolder)
    os.makedirs( backupFolder )

    # Copy current config
    shutil.copy2( cfgFile, backupFolder )

    # Move workers output
    nworkers = len(config['exec']['workers'])
    wmove = []
    for i in xrange(nworkers):
        wname = config['files']['worker'] % (i+1)
        wfile = os.path.join( saveFolder, wname )
        if os.path.isfile(wfile):
            wmove.append(wname)
            os.rename( wfile, os.path.join(backupFolder,wname) )

    # Compress job folders
    jmove = []
    if args.jobs:
        jobFolders = glob.glob(os.path.join( saveFolder, 'job_*' ))
        jobArchive = os.path.join( backupFolder, 'jobs.tar.bz2' )
        with tarfile.open( jobArchive, 'w:bz2' ) as tar:
            for job in jobFolders:
                jobName = os.path.basename(job)
                jmove.append( jobName )
                tar.append( job, arcname=jobName )

    # Write summary
    print 'Backed up to folder "%s" (%d output(s), %d folder(s))' % (backupFolder,len(wmove),len(jmove))
    