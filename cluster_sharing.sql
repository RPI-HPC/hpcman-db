CREATE TABLE cluster_sharing (
    snuuid bigint NOT NULL,
    cluster character varying(16) NOT NULL,
    node character varying(16) NOT NULL,
    parentnode character varying(16),
    share integer,
    description text,
    PRIMARY KEY(snuuid, cluster, node),
    FOREIGN KEY (snuuid, cluster) REFERENCES clusters(snuuid, name),
    FOREIGN KEY (snuuid, cluster, parentnode) REFERENCES cluster_sharing(snuuid, cluster, node) ON UPDATE CASCADE
);
