#!/bin/env/python

import sys
import argparse
import os
import json

# parse inputs
parser = argparse.ArgumentParser(prog=sys.argv[0])
parser.add_argument( 'name', nargs=1, help='Name of files to be created (eg +my/+nested/DerivedClass)' )
parser.add_argument( 'template', nargs=1, default=['default'], help='Name of the template to use. Default "default".' )
parser.add_argument( '--class', 
    nargs=1, default=[''], help="""
    Callable name of class (eg my.nested.DerivedClass).
    Required if first input 'name' is a nested path.
    """
)

args = parser.parse_args()

# create id and date of creation
id = time.strftime('%d-%b-%Y_%H%M%S')

# write data to conf file
with open( 'mapred.conf', 'w' ) as f:
    f.write(json.dumps({ 
        "queue": args.queue,
        "mailopt": args.mailopt,
        "email": args.email,
        "startup": args.startup 
    },indent=4))


def merge_two_dicts(x, y):
    '''Given two dicts, merge them into a new dict as a shallow copy.'''
    z = x.copy()
    z.update(y)
    return z