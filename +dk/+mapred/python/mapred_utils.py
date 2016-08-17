
import time
import json
import stat
import sys
import os

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

# Get formatted timestamp
def sortable_timestamp():
    return time.strftime('%Y%m%d-%H%M%S')

def matlab_timestamp():
    return time.strftime('%d-%b-%Y %H:%M:%S')

# Make a file executable
def make_executable( filename ):
    if os.path.isfile(filename):
        st = os.stat(filename)
        os.chmod( filename, st.st_mode | stat.S_IXUSR )

# Relink symbolic link
def relink( linkfile, newtarget ):
    if os.path.islink(linkfile):
        os.unlink(linkfile)

    os.symlink( newtarget, linkfile )

# Test is something is a string
def is_string( x, notempty=True ):
    return isinstance(x,basestring) and ( not notempty or x )

# Write JSON object to file
def write_json( filename, obj ):
    with open(filename,'w') as f:
        f.write(json.dumps( obj, indent=4 ))

# Read JSON file with comments
def read_json( filename ):
    with open(filename,'r') as f:
        return json.load(f)

# Search for config file in current directory
def find_config():

    # Look for config folder
    if os.path.isdir( 'config' ):
        return os.path.join( os.path.getcwd(), 'config/config.json' )

    # Look for config.json file
    if os.path.isfile( 'config.json' ):
        return os.path.join( os.path.getcwd(), 'config.json' )

    # Don't know what else to do
    raise "Could not find configuration file!"
