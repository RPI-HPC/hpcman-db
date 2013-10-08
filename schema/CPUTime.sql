CREATE TABLE cputime (
	username text,
	snuuid bigint,
-- timestamp was related to the job, now it's when this record hit the DB
	timestamp timestamp with time zone NOT NULL DEFAULT NOW(),
-- cputime and memory are ambiguous on purpose to allow for maximum flexibility
-- NOTE these two metrics are being deprecated by the addition of jobunits
	cputime bigint NOT NULL,
	memory bigint NOT NULL,
	jobstart timestamp with time zone NOT NULL,
	jobend timestamp with time zone NOT NULL,
-- units is mean to store a count of the resource consumed by the job
-- For example, this could be nodes, megabytes of memory, or cpu utilization
	units bigint NOT NULL,
-- jobname is meant to hold a string uniquely identifying a job to a scheduler
-- ex: LoadL step name, SGE job ID, etc
	jobname text,
-- Machines are distinguished by their hostnames
-- Determining a machine's type is not within the scope of this project;
--  extrapolating this from the hostname should be sufficient
	machine text,
	PRIMARY KEY(username, snuuid, jobname, machine, jobstart)
-- No referencial integrity is enforced here because usage records
--  should never be deleted, even if user accounts are removed.
);
