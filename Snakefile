# import 
from __future__ import print_function
import os
import sys
import re
import glob
import socket
import getpass
import subprocess
from distutils.spawn import find_executable
import pandas as pd

## load
configfile: 'config.yaml'

# setup
## pipeline utils
snake_dir = config['pipeline']['snakemake_folder']
include: snake_dir + 'bin/ll_pipeline_utils/Snakefile'
config_default(config, 'pipeline', 'name')
## custom functions
def make_fasta_splits(n_jobs):
    if str(n_jobs).lstrip().startswith('Skip'):
        n_jobs = 1
    zero_pad = len(str(n_jobs))
    zero_pad = '{0:0' + str(zero_pad) + 'd}'
    return [str(zero_pad.format(x+1)) for x in range(n_jobs)]

# setting paths
config['samples_file'] = os.path.abspath(config['samples_file'])
config['pipeline']['snakemake_folder'] = \
    os.path.abspath(config['pipeline']['snakemake_folder']) + '/'

## db create or update?
if config['pipeline']['config'] == 'create':
    include: snake_dir + 'bin/db_create/Snakefile'
elif config['pipeline']['config'] == 'update':
    include: snake_dir + 'bin/db_update/Snakefile'
else:
    raise ValueError('Pipeline "config" param not recognized')

## pipeline main
wildcard_constraints:
    sample="[^/]+"

localrules: all

rule all:
    input:
        all_which_input

