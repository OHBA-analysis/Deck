#!/bin/env/python

import os
import argparse
import mapred_utils as util
from datetime import datetime as date
from datetime import timedelta
import dateutil.parser as dateparser


# Search for config file in current directory
def search_config():

    # Look for config folder
    if os.path.isdir( 'config' ):
        return os.path.join( os.path.getcwd(), 'config/config.json' )

    # Look for config.json file
    if os.path.isfile( 'config.json' ):
        return os.path.join( os.path.getcwd(), 'config.json' )

    # Don't know what else to do
    raise "Could not find configuration file!"


# Read job information
def read_info( folder, jobid ):
    infofile = os.path.join( folder, 'job_' + str(jobid), 'info.json' )
    return util.read_json(infofile) if os.path.isfile(infofile) else {}


# Parse Matlab timestamp and return elapsed time
def time_remaining( startstamp, fraction ):

    # estimate remaining time in seconds
    remaining = date.now() - dateparser.parse(startstamp)
    remaining = remaining.total_seconds()
    remaining = remaining/fraction - remaining

    return timedelta( seconds=remaining )


# Worker progress report
def worker_progress( folder, workerid, jobids ):

    # Analyse status for each job in worker
    pgr = { 'running': 0.0, 'done': 0.0, 'fail': 0.0, 'total': len(jobids) }
    for i in jobids:
        info = read_info(folder,i)
        if info:
            pgr[ info['status'].lower() ] += 1

    # Estimate remaining time
    info = read_info(folder,jobid[0])
    if not info:
        remaining = '<undefined>'
    else:
        remaining = str(time_remaining( info['start'], pgr['done']/max(0.5,pgr['total']-pgr['fail']) ))

    print """
    Worker #%d [ %d %%, timeleft: %s ]
     + total : %d
     + done  : %d
     + fail  : %d
    """ % ( 
        workerid, 100.0 * (pgr['done']+pgr['fail'])/pgr['total'], remaining, 
        pgr['total'], pgr['done'], pgr['fail'] 
    )



if __name__ == '__main__':

    parser = argparse.ArgumentParser( prog=sys.argv[0] )
    parser.add_argument('config', nargs=1, default=[''], help='Configuration file (search for it if omitted)')
    args = parser.parse_args()

    # Get config file and read it
    cfgfile = args.config
    if not cfgfile:
        cfgfile = search_config()

    config = read_json(cfgfile)
    folder = config['folders']['save']

    # Analyse workers progress
    workers  = config['exec']['workers']
    nworkers = len(workers)
    for w in xrange(nworkers):
        worker_progress( folder, w+1, workers[w] )
