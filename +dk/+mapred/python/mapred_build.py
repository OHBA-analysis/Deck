#!/usr/bin/env python

import os
import argparse
import string
import json
import mapred_utils as util

# Check configuration contains all the required fields
def check_validity( cfg ):

    # Check that all fields are there
    assert { 'id', 'cluster', 'exec', 'files', 'folders' } <= set(cfg), '[root] Missing field(s).'
    
    # Check id
    tmp = cfg['id']
    assert util.is_string(tmp), '[id] Empty or invalid string.'

    # Check cluster
    tmp = cfg['cluster']
    valid_queues = ['veryshort', 'short', 'long', 'verylong', 'bigmem', 'cuda']
    valid_mailopts = ['b','e','a','s','n']
    assert { 'jobname', 'queue', 'email', 'mailopt' } <= set(tmp), '[cluster] Missing field(s).'
    assert util.is_string(tmp['jobname']), '[cluster.jobname] Empty or invalid string.'
    assert util.is_string(tmp['email']), '[cluster.email] Empty or invalid string.'
    assert tmp['queue'] in valid_queues, '[cluster.queue] Invalid queue.'
    assert tmp['mailopt'] in valid_mailopts, '[cluster.mailopt] Invalid mailopt.'

    # Check exec
    tmp = cfg['exec']
    assert { 'class', 'jobs', 'workers', 'options' } <= set(tmp), '[exec] Missing field(s).'
    assert util.is_string(tmp['class']), '[exec.class] Empty or invalid string.'
    assert isinstance(tmp['jobs'],list) and tmp['jobs'], '[exec.jobs] Empty or invalid list.'
    assert isinstance(tmp['workers'],list) and tmp['workers'], '[exec.workers] Empty or invalid list.'
    assert isinstance(tmp['options'],dict), '[exec.options] Invalid options.'

    # Because of bad Matlab JSON lib, workers can be a list of ints instead of a list of lists
    if not isinstance( tmp['workers'][0], list ):
        cfg['exec']['workers'] = [ [x] for x in cfg['exec']['workers'] ]
        tmp =  cfg['exec']
    
    assert sum(map( len, tmp['workers'] )) == len(tmp['jobs']), '[exec] Jobs/workers size mismatch.'

    # Check files
    tmp = cfg['files']
    assert { 'reduced', 'worker' } <= set(tmp), '[files] Missing field(s).'
    assert util.is_string(tmp['reduced']), '[files.reduced] Empty or invalid string.'
    assert util.is_string(tmp['worker']), '[files.worker] Empty or invalid string.'
    try:
        tpl = tmp['worker'] % (1)
    except:
        raise "[files.worker] Worker filename cannot be formatted."

    # Check folders
    tmp = cfg['folders']
    assert { 'start', 'work', 'save' } <= set(tmp), '[folders] Missing field(s).'
    assert util.is_string(tmp['start']), '[folders.start] Empty or invalid string.'
    assert util.is_string(tmp['save']), '[folders.save] Empty or invalid string.'
    assert util.is_string(tmp['work'],False), '[folders.work] Invalid string.' 


# Check existing output folder
msg_warning = """WARNING:
    Another configuration was found in folder '%s', and it looks compatible with the current one.
    Going through with this build might result in OVERWRITING existing results. 
    The options in the current configuration are:\n%s

    The options in the existing configuration are:\n%s

    Do you wish to proceed with the build?"""

def check_existing(cfg):

    folder = cfg['folders']['save']
    if os.path.isdir(folder):

        # If the reduced file already exists
        redfile = os.path.join( folder, cfg['files']['reduced'] )
        assert not os.path.isfile(redfile), \
            'Reduced file "%s" already exists, either back it up or change "files.reduced" field.' % (redfile)

        # If any of the workers outputs already exists
        nworkers = len(cfg['exec']['workers'])
        for i in xrange(nworkers):
            workerfile = os.path.join( folder, cfg['files']['worker'] % (i+1) )
            assert not os.path.isfile(workerfile), \
                'Worker file "%s" already exists, either back it up or change "files.worker" field.' % (workerfile)

        # If there is an existing config ..
        cfgfile = os.path.join( folder, 'config/config.json' )
        if os.path.isfile(cfgfile):

            # .. make sure it is compatible with the current one
            other = util.read_json(cfgfile)
            assert other['id'] == cfg['id'], \
                'Id mismatch with existing configuration "%s".' % (cfgfile)
            assert len(other['exec']['jobs']) == len(cfg['exec']['jobs']), \
                'Number of jobs mismatch with existing configuration "%s".' % (cfgfile)
            
            # format options as strings for comparison
            opt_new = json.dumps( cfg['exec']['options'], indent=4 )
            opt_old = json.dumps( other['exec']['options'], indent=4 )

            # Return true if the folder already exists
            return util.query_yes_no( msg_warning % ( folder, opt_new, opt_old ), "no" )
    
    return True


# Write new config to save folder
def make_config( cfg, folder ):

    # copy the whole config
    other = dict(cfg)

    # creat config folder if it doesnt exist
    cfg_folder = os.path.join( folder, 'config' )
    if not os.path.isdir( cfg_folder ):
        os.makedirs( cfg_folder )
        print 'Created folder "%s".' % (cfg_folder)

    # link and filename
    cfg_name  = 'config_%s.json' % (util.sortable_timestamp())
    link_file = os.path.join( cfg_folder, 'config.json' )
    cfg_file  = os.path.join( cfg_folder, cfg_name )

    util.write_json( cfg_file, other )
    util.relink( link_file, cfg_name )


# Template scripts
tpl_map = string.Template("""matlab -singleCompThread -nodisplay -r "cd '${startdir}'; startup; cd '${workdir}'; obj = ${classname}(); obj.run_worker('${savedir}',${workerid}); exit;" """)
tpl_reduce = string.Template("""matlab -singleCompThread -nodisplay -r "cd '${startdir}'; startup; cd '${workdir}'; obj = ${classname}(); obj.run_reduce('${savedir}'); exit;" """)
tpl_submit = string.Template("""#!/bin/bash

# remove info in all job subfolders
for folder in job_*; do
    [ -f $${folder}/info.json ] && rm -f $${folder}/info.json 
done

# submit map/reduce job to the cluster
mid=$$(fsl_sub -q ${queue}.q -M ${email} -m ${mailopt} -N ${jobname} -l "${logdir}" -t "${mapscript}")
rid=$$(fsl_sub -j $${mid} -q ${queue}.q -M ${email} -m ${mailopt} -N ${jobname} -l "${logdir}" "${redscript}")

# Show IDs
echo "Submitted map with ID $${mid} and reduce with ID $${rid}. Use qstat and mapred_status to monitor the progress."
""")

# Write scripts according to current config
def make_scripts( cfg, folder ):

    # default configuration
    workdir = cfg['folders']['work']
    if not workdir:
        workdir = cfg['folders']['start']

    # substitution values from config
    sub = dict(cfg['cluster'])
    sub.update({
          'savedir': cfg['folders']['save'],
         'startdir': cfg['folders']['start'],
          'workdir': workdir,
        'classname': cfg['exec']['class'],
           'logdir': 'logs',
        'mapscript': 'map.sh',
        'redscript': 'reduce.sh'
    })

    # put the scripts together
    nworkers = len(cfg['exec']['workers'])
    scripts = {
           'map.sh': "\n".join([ tpl_map.substitute(sub,workerid=(i+1)) for i in xrange(nworkers) ]) + "\n",
        'reduce.sh': tpl_reduce.substitute(sub) + "\n",
           'submit': tpl_submit.substitute(sub)
    }

    # create log folder
    logdir = os.path.join( folder, 'logs' )
    if not os.path.isdir(logdir):
        os.mkdir(logdir)

    # create scripts and make executable
    for name,text in scripts.iteritems():
        sname = os.path.join(folder,name)
        with open( sname, 'w' ) as f:
            f.write(text)
        
        util.make_executable(sname)
    

# Success message
msg_success = """
Successful build (%d jobs across %d workers). To submit to the cluster, run:
    %s
"""

if __name__ == '__main__':

    parser = argparse.ArgumentParser( prog='mapres_build' )
    parser.add_argument('config', nargs=1, help='Configuration file to be built')
    args = parser.parse_args()

    # Try different extensions in case it's missing
    config = args.config[0]
    if os.path.isfile(config + '.mapred.json'):
        config = config + '.mapred.json'
    elif os.path.isfile(config + '.json'):
        config = config + '.json'
    else:
        assert os.path.isfile(config), 'File "%s" not found.' % (config)

    # Load config and validate it
    config = util.read_json(config)
    check_validity(config)

    # Process it
    if check_existing(config):

        # Create save folder
        folder = config['folders']['save']
        if not os.path.isdir( folder ):
            os.makedirs( folder )
            print 'Created folder "%s".' % (folder)

        # Create config 
        make_config( config, folder )

        # Create scripts
        make_scripts( config, folder )

        # Success message
        njobs = len(config['exec']['jobs'])
        nworkers = len(config['exec']['workers'])
        print msg_success % ( njobs, nworkers, os.path.join(folder,'submit') )

