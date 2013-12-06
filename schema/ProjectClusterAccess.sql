CREATE TABLE project_cluster_access (
    projid bigint NOT NULL,
    cluster character varying(16) NOT NULL,
    snuuid bigint NOT NULL,
    share bigint default 0,
    parentnode character varying(16),
    cpuquota int,
    PRIMARY KEY (snuuid, projid, cluster),
    FOREIGN KEY (snuuid, projid) REFERENCES projects(snuuid, projid) ON UPDATE CASCADE,
    FOREIGN KEY (snuuid, cluster, parentnode) REFERENCES cluster_sharing(snuuid, cluster, node) ON UPDATE CASCADE
);
