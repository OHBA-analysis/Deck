#!/bin/env/python

import sys
import time
import json
import shutil
import argparse
import os
import string

# Template scripts
tpl_task_map = string.Template('matlab -singleCompThread -nodisplay -r "cd $StartDir; startup; cd $WorkDir; mr = $ClassName(); mr.run_worker($SaveDir);exit;"')



# From http://stackoverflow.com/a/3041990/472610
def query_yes_no( question, default=None ):
    
    # Set prompt depending on default
    if default is None:
        prompt = " (yes/no) "
    elif default == "yes":
        prompt = " ([yes]/no) "
    elif default == "no":
        prompt = " (yes/[no]) "
    else:
        raise ValueError("Invalid default answer: '%s'" % default)

    # Ask question until a valid answer is given
    valid = {"yes": True, "no": False}
    while True:
        sys.stdout.write(question + prompt)
        choice = raw_input().strip().lower()
        if default is not None and choice == '':
            return valid[default]
        elif choice in valid:
            return valid[choice]
        else:
            sys.stdout.write("Please respond either 'yes' or 'no'.\n")


# Check configuration contains all the required fields
def check_config( cfg ):

    # Check that all fields are there
    assert { 'date', 'exec', 'folder' } <= set(cfg), '[root] Missing field(s).'
    
    # Check date
    tmp = cfg['date']
    assert isinstance(tmp,str) and tmp, '[date] Empty or invalid string.'

    # Check exec
    tmp = cfg['exec']
    assert { 'class', 'jobs', 'workers', 'options' } <= set(tmp), '[exec] Missing field(s).'
    assert isinstance(tmp['class'],str) and tmp['class'], '[exec.class] Empty or invalid string.'
    assert isinstance(tmp['jobs'],list) and tmp['jobs'], '[exec.jobs] Empty or invalid list.'
    assert isinstance(tmp['workers'],list) and tmp['workers'], '[exec.workers] Empty or invalid list.'
    assert isinstance(tmp['options'],dict), '[exec.options] Invalid options.'
    assert sum(map( len, tmp['workers'] )) == len(tmp['jobs']), '[exec] Jobs/workers size mismatch.'

    # Check cluster
    tmp = cfg['cluster']
    valid_queues = ['veryshort', 'short', 'long', 'verylong', 'bigmem', 'cuda']
    valid_mailopts = ['b','e','a','s']
    assert { 'name', 'queue', 'email', 'mailopt' } <= set(tmp), '[cluster] Missing field(s).'
    assert isinstance(tmp['name'],str) and tmp['name'], '[cluster.name] Empty or invalid string.'
    assert isinstance(tmp['email'],str), '[cluster.email] Invalid string.'
    assert tmp['queue'] in valid_queues, '[cluster.queue] Invalid queue.'
    assert tmp['mailopt'] in valid_mailopts, '[cluster.mailopt] Invalid mailopt.'

    # Check folder
    tmp = cfg['folder']
    assert { 'start', 'work', 'save' } <= set(tmp), '[folder] Missing field(s).'
    assert isinstance(tmp['start'],str) and tmp['start'], '[cluster.start] Empty or invalid string.'
    assert isinstance(tmp['save'],str) and tmp['save'], '[cluster.save] Empty or invalid string.'
    assert isinstance(tmp['work'],str), '[cluster.work] Invalid string.' 

# Check existing output folder
def check_existing(cfg):

    folder = cfg['folder']['save']
    if os.path.isdir(folder):

        # If there is an existing config ..
        cfgfile = os.path.join( folder, 'config/config.json' )
        if os.path.isdir(cfgfile):

            # .. make sure it is compatible with the current one
            other = json.load(cfgfile)
            assert len(other['exec']['jobs']) == len(cfg['exec']['jobs']), \
                'Inconsistency with existing configuration "%s".' % (cfgfile)
            
        # Return true if the folder already exists
        return True
    else:
        return False



# Parse inputs
parser = argparse.ArgumentParser( prog=sys.argv[0] )
parser.add_argument('config', nargs=1, help='Configuration file to be built')
parser.add_argument('-n','--nosubmit', help='Do not submit after the build.', action='store_true')

args = parser.parse_args()


# Load and check config
config = json.load(args.config)

check_config(config)
check_existing(config)


# Edit and save config

pepper_dir = os.path.split(os.path.realpath(__file__))[0] # Main repo directory
main_conf = os.path.join(pepper_dir,'pepper.conf')

if os.path.isfile('pepper.conf'): 
	conf_name = 'pepper.conf'
elif os.path.isfile(main_conf):
	conf_name = main_conf
else:
	print"Config file 'pepper.conf' was not found!"
	with open(main_conf,'w') as f:
		f.write("code_dir = '<<< EDIT PEPPER.CONF FIRST>>>' # Folder where your startup.m lives\n")
		f.write("user_email = 'me@server.com' # Email address for job notifications\n")
		f.write("default_jobname = 'pepper' # If you don't specify a job name, this will be used automatically\n")
	print "Wrote default config file"
	print main_conf
	print "Edit it and try again"
	sys.exit()

execfile(conf_name) # Load user config

if not os.path.isdir(code_dir):
	print "Code directory not found: %s" % (code_dir)
	sys.exit()
if not os.path.isfile(os.path.join(code_dir,'startup.m')):
	print "Startup file %s not found" % (os.path.isfile(os.path.join(code_dir,'startup.m')))
	print "This file must exist, even if it is empty"
	sys.exit()

def get_foldername(fname):
	if os.path.exists(fname):
		fname = fname + '_' + time.strftime('%Y%m%d') # Append the date

	if os.path.exists(fname):
		idx = 1
		fname = fname + '_' + str(idx); # Append a counter
		while os.path.exists(fname):
			idx += 1
			fname = fname[:-1] + str(idx);

	return fname

parser = argparse.ArgumentParser(prog='submit')
parser.add_argument('n_workers', nargs=1, help='Number of workers')
parser.add_argument('filename', nargs=1, help='Name of .m file storing Pepper object to be run')
parser.add_argument('--argstring', nargs=1,default=['()'], help='Pepper argument string')
parser.add_argument('--queue', default=['short'], nargs=1, help='Queue name: [veryshort, short, long, verylong, bigmem]') # Short is appropriate because longer jobs will throw an error within 4 hours rather than 24
parser.add_argument('--mailto', default=[user_email], nargs=1, help='Email address for notifications')
parser.add_argument('--name', default=[default_jobname], nargs=1, help='Job name')
parser.add_argument('--mail_conditions', default=['n'], nargs=1, help='Mail condition flags - [b]egin, [e]nd, [a]bort, [s]uspend, [n]o mail. Default "n"')

args = parser.parse_args()
fname = args.filename[0]
pep_argstring = args.argstring[0]

if (not pep_argstring.startswith('(')) or (not pep_argstring.endswith(')')) or ('"' in pep_argstring):
	print("Argument string should start and end with brackets, and use single quotes internally")
	sys.exit()

if not fname.endswith('.m'):
	print("Input file should have a .m extension")
	sys.exit()
n_workers = int(args.n_workers[0])
pepper_name = os.path.splitext(fname)[0];
folder_name = get_foldername(pepper_name);
work_dir = os.path.abspath(folder_name);
os.mkdir(work_dir)
shutil.copyfile(fname,os.path.join(work_dir,fname))
os.mkdir(os.path.join(work_dir,'logs'))
os.mkdir(os.path.join(work_dir,'worker_files'))

# Now, write the job file
with open(os.path.join(work_dir,'worker_commands.sh'),'w') as f:
	for i in xrange(1,n_workers+1):
		f.write('sleep $[ ( $RANDOM %% 20 )  + 1 ]s && matlab -singleCompThread -nojvm -nodisplay -r "cd %s; startup; cd %s; pep = %s%s; pep.cluster_run(%d,%d);exit;"\n' % (code_dir,work_dir,pepper_name,pep_argstring,i,n_workers))

with open(os.path.join(work_dir,'assemble.sh'),'w') as f:
	f.write('matlab -singleCompThread -nojvm -nodisplay -r "cd %s; startup; cd %s; pep = %s%s; pep.assemble();exit;"\n' % (code_dir,work_dir,pepper_name,pep_argstring))

with open(os.path.join(work_dir,'fsl_sub_command.sh'),'w') as f:
	f.write("jid=`/opt/fmrib/fsl/bin/fsl_sub -q %s.q -M %s -m %s -N %s -l %s -t %s`\n" % (args.queue[0],args.mailto[0],args.mail_conditions[0],args.name[0],os.path.join(work_dir,'logs'),os.path.join(work_dir,'worker_commands.sh')))
	f.write("/opt/fmrib/fsl/bin/fsl_sub -j $jid -q %s.q -M %s -m %s -N %s -l %s %s\n" % (args.queue[0],args.mailto[0],args.mail_conditions[0],args.name[0],os.path.join(work_dir,'logs'),os.path.join(work_dir,'assemble.sh')))

os.system('chmod u+x %s' % os.path.join(work_dir,'fsl_sub_command.sh'))
os.system('chmod u+x %s' % os.path.join(work_dir,'worker_commands.sh'))
os.system('chmod u+x %s' % os.path.join(work_dir,'assemble.sh'))
os.system('bash %s >> /dev/null' % os.path.join(work_dir,'fsl_sub_command.sh'))

print "Job submitted - %s" % work_dir
