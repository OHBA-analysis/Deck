classdef Abstract < handle
    
    properties (Abstract,Constant)
        name
        id
    end
    
    methods (Abstract)
        
        % Should return a struct-array the same length as the unrolled loop with named parameters.
        %
        % If index is specified, then output should correspond to the structure at that index in the array output.
        %
        inputs = get_inputs(self,index);
        
        % First arg should be a structure with named parameters (typically as returned by get_inputs(k)).
        %
        % Second arg should be a path to the folder in which the routine may save data as needed.
        %
        % Additional inputs should be options that can be parsed by dk.obj.kwArgs (eg named options, or struct).
        %
        output = process(self,inputs,folder,varargin);
        
    end
    
    methods

        function cfg = load_config(self)
            cfg = dk.json.load(self.config_file);
            cfg = fix_config(cfg);
        end

        function cfg = configure(self,nworkers,varargin)

            cfg     = self.load_config();
            inputs  = self.get_inputs();
            njobs   = numel(inputs);
            workers = split_jobs( njobs, nworkers );
            options = dk.obj.kwArgs(varargin{:});
            
            % edit the exec field
            cfg.exec.class   = self.name;
            cfg.exec.jobs    = inputs;
            cfg.exec.workers = workers;
            cfg.exec.options = options.parsed;

            % save edited config
            dk.println('[MapReduce] Configuration edited in "%s".',self.config_file);
            dk.json.save(self.config_file,cfg);

        end
        
    end
    
    methods (Hidden)
        
        function f = config_file(self)
            f = [dk.mapred.name2relpath(self.name) '.mapred.json'];
        end

        function config = load_running_config( self, folder )

            % load config (contains options)
            config = dk.json.load(fullfile( folder, 'config/config.json' ));
            config = fix_config(config);

            % make sure the ID is correct
            assert( strcmp(config.id,self.id), 'ID mismatch between class and running config.' );
            
            % save the folder from where the config was loaded
            % this allows to move the folder around without affecting the processing
            config.folder = folder;

        end

        function output = run_job( self, workerid, jobid, config )
            
            % create folder for storage if it doesn't already exist
            jobfolder = fullfile( config.folders.save, sprintf('job_%d',jobid) );
            if ~dk.fs.is_dir( jobfolder )
                dk.assert( mkdir(jobfolder), 'Could not create folder "%s".', jobfolder );
            end
            
            % parse options and make sure it's a struct
            options = config.exec.options;
            if isempty(options)
                options = struct();
            end

            % update info
            info.worker  = workerid;
            info.job     = jobid;
            info.inputs  = config.exec.jobs(jobid);
            info.options = options;
            info.status  = 'running';
            info.start   = get_timestamp();
            info.stop    = '';
            info.errmsg  = '';
            dk.json.save( fullfile(jobfolder,'info.json'), info );
            
            % run job
            try
                output = self.process( info.inputs, jobfolder, info.options );
                info.status = 'done';
            catch ME
                output = [];
                info.status = 'failed';
                info.errmsg = ME.message;
            end
            
            % update info
            info.stop = get_timestamp();
            dk.json.save( fullfile(jobfolder,'info.json'), info );
            
        end
        
        function output = run_worker( self, folder, workerid )
            
            % load config (contains options)
            config = self.load_running_config(folder);

            % set worker id from environment if not provided
            if nargin < 3
                workerid = get_task_id();
            end
            
            % get all jobs to run
            jobids = config.exec.workers{workerid};
            njobs  = numel(jobids);
            
            dk.println('[MapReduce.START] Worker #%d',workerid);
            dk.println('         folder : %s',pwd);
            dk.println('           host : %s',dk.env.hostname);
            dk.println('           date : %s',get_timestamp);
            dk.println('          njobs : %d',njobs);
            dk.println('-----------------\n');
                        
            timer  = dk.time.Timer();
            output = cell(1,njobs);
            
            for i = 1:njobs
                jobid = jobids(i);
                try
                    output{i} = self.run_job( workerid, jobid, config );
                    dk.println('Job #%d (%d/%d, timeleft %s)...',jobid,i,njobs,timer.timeleft_str(i/njobs));
                catch
                    dk.println('Job #%d (%d/%d)... FAILED',jobid,i,njobs);
                end
            end
            
            % save output file
            outfile = fullfile( folder, sprintf( config.files.worker, workerid ) );
            dk.println('\n\t Saving output file to "%s" (%s)...',outfile,get_timestamp);
            save( outfile, '-v7.3', 'output' );
            
            fprintf('\n\n');
            dk.println('[MapReduce.STOP] Worker #%d',workerid);
            dk.println('          date : %s',get_timestamp);
            dk.println('        output : %s',outfile);
            dk.println('----------------\n');
            
        end

        function output = run_reduce( self, folder )

            % load config (contains options)
            config = self.load_running_config(folder);

            % prepare output
            njobs    = numel(config.exec.jobs);
            nworkers = numel(config.exec.workers);
            outfile  = fullfile( folder, config.files.reduce );

            dk.println('[MapReduce.START] Reduce');
            dk.println('         folder : %s',pwd);
            dk.println('           host : %s',dk.env.hostname);
            dk.println('           date : %s',get_timestamp);
            dk.println('       nworkers : %d',nworkers);
            dk.println('-----------------\n');

            if dk.fs.is_file(outfile)
                warning( 'Reduce file "%s" already exists, outputs will be merged.', outfile );
                output = load(outfile);
                output = output.output;
                assert( numel(output)==njobs, 'Wrong number of jobs in existing reduce file, aborting.' );
            else
                output = cell( 1, njobs );
            end

            % concatenate outputs
            timer = dk.time.Timer();
            for i = 1:nworkers

                workerfile = fullfile( folder, sprintf( config.files.worker, i ) );
                try 
                    workerdata = load( workerfile );
                    output( config.exec.workers{i} ) = workerdata.output;
                    dk.println('Worker %d/%d merged, timeleft %s...',i,nworkers,timer.timeleft_str(i/nworkers));
                    % delete( worderfile );
                catch
                    dk.println('Worker %d/%d... FAILED',i,nworkers);
                end
            end

            % save output file
            dk.println('\n\t Saving reduced file to "%s" (%s)...',outfile,get_timestamp);
            save( outfile, '-v7.3', 'output' );

            fprintf('\n\n');
            dk.println('[MapReduce.STOP] Reduce');
            dk.println('          date : %s',get_timestamp);
            dk.println('        output : %s',outfile);
            dk.println('----------------\n');

        end
        
    end
    
end

function t = get_timestamp()

    % return a nice timestamp with date and time
    t = datestr(now,'dd-mmm-yyyy HH:MM:SS');
    
end

function id = get_task_id()
    
    % detect grid environment (for now, only SGE)
    id = str2num(getenv('SGE_TASK_ID'));

end

function jobids = split_jobs( njobs, nworkers )

    assert( nworkers>0 && njobs>0, 'Inputs should be positive.' );

    njobs_per_worker  = ceil( njobs / nworkers );
    jobstrides = [0,cumsum(njobs_per_worker*ones(1,nworkers-1)),njobs];
    jobids = cell( 1, nworkers );
    for i = 1:nworkers
        jobids{i} = (1+jobstrides(i)):jobstrides(i+1);
    end
    
end

% apply corrections because of crap JSON parsing
function config = fix_config(config)

    % make sure the workers are stored in a cell
    if ~iscell(config.exec.workers)
        config.exec.workers = arrayfun( @(x) x, config.exec.workers, 'UniformOutput', false );
    end

end
