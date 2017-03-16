#!/usr/bin/env python

import os
import glob
import shutil
import tarfile
import argparse
import mapred_utils as util

if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('--folder', default=os.getcwd(), help='The "save folder" of the map/reduce task being backed up')
    parser.add_argument('--name', default=util.sortable_timestamp(), help='Name of the subfolder to create in the data directory')
    parser.add_argument('--nojob', action='store_true', help='Exclude jobs from backup')
    args = parser.parse_args()

    # Make sure save folder exists
    saveFolder = args.folder
    assert os.path.isdir(saveFolder), 'Folder not found: ' + saveFolder

    # Find config file
    cfgFile = os.path.join( saveFolder, 'config', 'config.json' )
    assert os.path.isfile(cfgFile), 'Could not find config file: ' + cfgFile
    config = util.read_json(cfgFile)

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

    # Move log folder (should match substitution in mapred_build)
    try:
        logFolder = os.path.join(saveFolder,'logs')
        shutil.move( logFolder, backupFolder )
        os.makedirs( logFolder ) # make a new one
    except:
        print "Could not find or move logs folder: " + logFolder

    # Compress job folders
    jmove = []
    if not args.nojob:
        jobFolders = glob.glob(os.path.join( saveFolder, 'job_*' ))
        jobArchive = os.path.join( backupFolder, 'jobs.tar.bz2' )
        print "Compressing %d jobs outputs to archive %s (please wait)..." % ( len(jobFolders), jobArchive )
        with tarfile.open( jobArchive, 'w:bz2' ) as tar:
            for job in jobFolders:
                jobName = os.path.basename(job)
                jmove.append( jobName )
                tar.add( job, arcname=jobName )

    # Write summary
    print 'Backed up to folder "%s" (%d output(s), %d folder(s))' % (backupFolder,len(wmove),len(jmove))
    