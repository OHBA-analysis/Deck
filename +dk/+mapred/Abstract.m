classdef MapReduce < handle
    
    properties (Abstract)
        name
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
        
        % First arg should be the number of workers among which the jobs should be distributed.
        %
        % This function should call create_config internally with the name of the derived class.
        %
        configure(self,nworkers,varargin);
        
    end
    
    methods

        function cfg = load_config(self)
            cfg = dk.json.load([self.name '.mapred']);
        end
        
    end
    
    methods (Hidden)
        
        function output = run_job( self, workerid, jobid, config )
            
            % create folder for storage if it doesn't already exist
            jobfolder = fullfile( config.folder, sprintf('job_%d',jobid) );
            if ~dk.fs.is_dir( jobfolder )
                dk.assert( mkdir(jobfolder), 'Could not create folder "%s".', jobfolder );
            end
            
            % update info
            info.worker  = workerid;
            info.job     = jobid;
            info.inputs  = config.jobs(jobid);
            info.options = config.options;
            info.status  = 'running';
            info.start   = get_timestamp();
            info.stop    = '';
            info.errmsg  = '';
            dk.json.save( fullfile(jobfolder,'info.json'), info );
            
            % run job
            try
                output = self.process(config.inputs,jobfolder,config.options);
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
            config  = dk.json.load(fullfile( folder, 'config/config.json' ));
            
            % set worker id from environment if not provided
            if nargin < 3
                workerid = get_task_id();
            end
            
            % save the folder from where the config was loaded
            % this allows to move the folder around without affecting the processing
            config.folder  = folder;
            
            % get all jobs to run
            jobids = config.workers{workerid};
            njobs  = numel(jobids);
            
            dk.println('[MapReduce.START] Worker #%d');
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
            outfile = fullfile( folder, sprintf('worker_%d_output.mat',workerid) );
            dk.println('\n\t Saving output file to "%s" (%s)...',outfile,get_timestamp);
            save( outfile, '-v7.3', 'output' );
            
            fprintf('\n\n');
            dk.println('[MapReduce.STOP] Worker #%d');
            dk.println('          date : %s',get_timestamp);
            dk.println('        output : %s',outfile);
            dk.println('----------------\n');
            
        end
        
        function config = create_config( self, className, nworkers, options )
            
            config  = self.load_config();
            inputs  = self.get_inputs();
            njobs   = numel(inputs);
            workers = split_jobs( njobs, nworkers );
            
            % edit the exec field
            config.exec.class   = className;
            config.exec.jobs    = inputs;
            config.exec.workers = workers;
            config.exec.options = options;

            % save edited config
            dk.json.save([self.name '.mapred'],config);
            
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