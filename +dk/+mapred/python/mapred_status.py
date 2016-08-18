#!/usr/bin/env python

import os
import argparse
import mapred_utils as util
from datetime import datetime as date
from datetime import timedelta
from dateutil import parser as dateparser


# Read job information
def read_info( folder, jobid ):
    infofile = os.path.join( folder, 'job_' + str(jobid), 'info.json' )
    return util.read_json(infofile) if os.path.isfile(infofile) else {}


# Parse Matlab timestamp and return elapsed time
def time_remaining( startstamp, fraction ):

    # estimate remaining time in seconds
    if fraction > 0:
        remaining = date.now() - dateparser.parse(startstamp)
        remaining = remaining.total_seconds()
        remaining = remaining/float(fraction) - remaining
        return timedelta( seconds=remaining ) 
    else:
        return None

# Worker progress report
def worker_progress( folder, workerid, jobids ):

    # Analyse status for each job in worker
    pgr = { 'running': 0.0, 'done': 0.0, 'failed': 0.0, 'total': len(jobids) }
    for job in jobids:
        info = read_info(folder,job)
        if info:
            pgr[ info['status'].lower() ] += 1

    # Estimate remaining time
    info = read_info(folder,jobids[0])
    if not info:
        remaining = '<undefined>'
    else:
        remaining = str(time_remaining( info['start'], pgr['done']/max(0.5,pgr['total']-pgr['failed']) ))

    head = 'Worker #%d [ %d %%, timeleft: %s ]' % \
        ( workerid, 100.0 * (pgr['done']+pgr['failed'])/pgr['total'], remaining )
    
    if pgr['failed'] > 0:
        print colored(head,'white','on_red',attrs=['bold','blink'])
    elif pgr['done'] == pgr['total']:
        print colored(head,'green',attrs=['bold'])
    else:
        print head

    print """
     + total  : %d
     + done   : %d
     + failed : %d
    """ % ( pgr['total'], pgr['done'], pgr['failed'] )



if __name__ == '__main__':

    parser = argparse.ArgumentParser( prog='mapres_status' )
    parser.add_argument('--config', nargs=1, default=[''], help='Configuration file (search for it if omitted)')
    args = parser.parse_args()

    # Get config file and read it
    cfgfile = args.config[0]
    if not cfgfile:
        cfgfile = util.find_config()

    config = util.read_json(cfgfile)
    folder = config['folders']['save']

    # Analyse workers progress
    workers  = config['exec']['workers']
    nworkers = len(workers)
    for w in xrange(nworkers):
        worker_progress( folder, w+1, workers[w] )
