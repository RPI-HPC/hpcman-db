CREATE TABLE clusters (
    name character varying(16) NOT NULL,
    description text,
    primary_slurm_controller character varying(63),
    backup_slurm_controller character varying(63),
    snuuid bigint not null,
    PRIMARY KEY(name, snuuid)
);
