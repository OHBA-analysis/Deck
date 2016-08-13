#!/bin/env/python

import os
import sys
import argparse
import string
import mapred_utils as util


# Check configuration contains all the required fields
def check_validity( cfg ):

    # Check that all fields are there
    assert { 'id', 'cluster', 'exec', 'files', 'folders' } <= set(cfg), '[root] Missing field(s).'
    
    # Check id
    tmp = cfg['id']
    assert isinstance(tmp,str) and tmp, '[id] Empty or invalid string.'

    # Check cluster
    tmp = cfg['cluster']
    valid_queues = ['veryshort', 'short', 'long', 'verylong', 'bigmem', 'cuda']
    valid_mailopts = ['b','e','a','s']
    assert { 'jobname', 'queue', 'email', 'mailopt' } <= set(tmp), '[cluster] Missing field(s).'
    assert isinstance(tmp['jobname'],str) and tmp['jobname'], '[cluster.jobname] Empty or invalid string.'
    assert isinstance(tmp['email'],str) and tmp['email'], '[cluster.email] Empty or invalid string.'
    assert tmp['queue'] in valid_queues, '[cluster.queue] Invalid queue.'
    assert tmp['mailopt'] in valid_mailopts, '[cluster.mailopt] Invalid mailopt.'

    # Check exec
    tmp = cfg['exec']
    assert { 'class', 'jobs', 'workers', 'options' } <= set(tmp), '[exec] Missing field(s).'
    assert isinstance(tmp['class'],str) and tmp['class'], '[exec.class] Empty or invalid string.'
    assert isinstance(tmp['jobs'],list) and tmp['jobs'], '[exec.jobs] Empty or invalid list.'
    assert isinstance(tmp['workers'],list) and tmp['workers'], '[exec.workers] Empty or invalid list.'
    assert isinstance(tmp['options'],dict), '[exec.options] Invalid options.'
    assert sum(map( len, tmp['workers'] )) == len(tmp['jobs']), '[exec] Jobs/workers size mismatch.'

    # Check files
    tmp = cfg['files']
    assert { 'reduced', 'worker' } <= set(tmp), '[files] Missing field(s).'
    assert isinstance(tmp['reduced'],str) and tmp['reduced'], '[files.reduced] Empty or invalid string.'
    assert isinstance(tmp['worker'],str) and tmp['worker'], '[files.worker] Empty or invalid string.'
    try:
        tpl = tmp['worker'] % (1)
    except:
        raise "[files.worker] Worker filename cannot be formatted."

    # Check folders
    tmp = cfg['folders']
    assert { 'start', 'work', 'save' } <= set(tmp), '[folders] Missing field(s).'
    assert isinstance(tmp['start'],str) and tmp['start'], '[folders.start] Empty or invalid string.'
    assert isinstance(tmp['save'],str) and tmp['save'], '[folders.save] Empty or invalid string.'
    assert isinstance(tmp['work'],str), '[folders.work] Invalid string.' 


# Check existing output folder
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
            other = json.load(cfgfile)
            assert other['id'] == cfg['id'], \
                'Id mismatch with existing configuration "%s".' % (cfgfile)
            assert len(other['exec']['jobs']) == len(cfg['exec']['jobs']), \
                'Number of jobs mismatch with existing configuration "%s".' % (cfgfile)
            
            # format options as strings for comparison
            opt_new = json.dumps( cfg['exec']['options'], indent=4 )
            opt_old = json.dumps( other['exec']['options'], indent=4 )

            # Return true if the folder already exists
            return util.query_yes_no( """
            An other configuration was found in folder '%s', and it looks compatible with the current one.
            Going through with this build might result in OVERWRITING existing results. 
            The options in the current configuration are:
            %s

            The options in the existing configuration are:
            %s

            Do you wish to proceed with the build?""" % ( folder, opt_new, opt_old ), "no" )
    
    return True


# Write new config to save folder
def make_config( cfg, folder ):

    # copy the whole config
    other = dict(cfg)

    # creat config folder if it doesnt exist
    cfg_folder = os.path.join( folder, 'config' )
    if not os.path.isdir( cfg_folder ):
        os.makedirs( cfg_folder )

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
jid=$$(fsl_sub -q ${queue}.q -M ${email} -m ${mailopt} -N ${jobname} -l "${logdir}" -t "${mapscript}")
fsl_sub -j $${jid} -q ${queue}.q -M ${email} -m ${mailopt} -N ${jobname} -l "${logdir}" "${redscript}"
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
    scripts['map.sh'] = "\n".join([ tpl_map.substitute(sub,workerid=(i+1)) for i in xrange(nworkers) ]) 
    scripts['reduce.sh'] = tpl_reduce.substitute(sub)
    scripts['submit'] = tpl_submit.substitute(sub)

    # create log folder
    logdir = os.path.join( folder, 'logs' )
    if not os.path.isdir(logdir):
        os.mkdir(logdir)

    # create scripts
    for name,text in scripts.iteritems():
        sname = os.path.join(folder,sname)
        with open( sname, 'w' ) as f:
            f.write(text)
        
    # make submit executable
    util.make_executable(os.path.join(folder,'submit'))
        

# Success message
msg_success = """
Successful build (%d jobs across %d workers). To submit to the cluster, run:
    %s
"""

if __name__ == '__main__':

    parser = argparse.ArgumentParser( prog=sys.argv[0] )
    parser.add_argument('config', nargs=1, help='Configuration file to be built')
    args = parser.parse_args()

    config = util.read_json(args.config)
    check_validity(config)

    if check_existing(config):

        # Create save folder
        folder = config['folders']['save']
        if not os.path.isdir( folder ):
            os.makedirs( folder )

        # Create config 
        make_config( config, folder )

        # Create scripts
        make_scripts( config, folder )

        # Success message
        njobs = len(cfg['exec']['jobs'])
        nworkers = len(cfg['exec']['workers'])
        print success_msg % ( njobs, nworkers, os.path.join(folder,'submit') )

