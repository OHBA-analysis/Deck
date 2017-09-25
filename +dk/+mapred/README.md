# Map-Reduce Framework

This submodule allows you to distribute the computation of some iterative process (typically something that can be written in the form of a for-loop with independent iterations) on a computing cluster.

It contains Python scripts that should be **installed** on the user profile. Specifically, they should be copied to a folder that is on the user's `PATH`.
For now, the scripts assume that the user is using `fsl_sub` to submit a parallel job to the computing cluster, but this can be changed if necessary.

## Overview

Consider the following loop:
```matlab
% define options that apply to the entire loop
Pre = pre_processing();

for i = 1:n

    % get iteration-specific parameters
    Param = acquire_parameters(i);

    % do something, and store results
    Res{i} = repetitive_task( Param, Pre );

end
```

The submodule `dk.mapred` essentially allows you to store the pre-processing results in a configuration file, and write down the implementations of the functions `acquire_parameters` and `repetitive_task` into a class.
Note that each iteration _must_ be independent from the others; that is, the for loop should be readily parallelisable.

The main purpose of this submodule is to:

 - break down the for-loop into groups of indices,
 - run each group on a separate compute node,
 - and aggregate the results once all groups are computed.

The program in charge of running each group is called a **worker**, and each task corresponding to a specific index is called a **job**.

In addition, this implementation allows you to save intermediary results into a job-specific folder, and return results to be aggregated as the main output. Ideally, the main results should be reasonably small in size (especially if there are a lot of iterations), but the intermediary results can be arbitrarily large.

## Define your processing task

Assuming that Deck is on your Matlab path, run:
```matlab
dk.mapred.init( 'MyProcessingTask' )
```

This should create **two** new files in the current directory:

 - `MyProcessingTask.m`
 - `MyProcessingTask.mapred.json`

The first file contains a class definition with two methods.

 - `inputs = get_inputs(self,index)`: this method should return the parameters (as a struct) for the iteration corresponding to the input index, or a struct-array for **all** (resp. a subset of) iterations if called without index (resp. with an array of indices).
 You might also want to have a look at `dk.struct.array` for a practical implementation.
 - `output = process(self,inputs,folder,varargin)`: this method should run the computations of interest for a given structure of inputs, and will be invoked with a folder name to save intermediary results, and an additional structure of options if you specified any (see configuration below).

Note that for testing the processing locally on your machine, before you run it on the cluster, you may want to implement the method `process` such that it requires a single argument.

## Creating your own template



- Installation
- Configuration
- `dk.mapred.install`
- `dk.mapred.Abstract`
- `dk.mapred.init`
- Templates
- Python interface
