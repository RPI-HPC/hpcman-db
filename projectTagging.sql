CREATE TABLE project_tagging (
    projid bigint NOT NULL,
    tag character varying(50) NOT NULL,
    snuuid bigint NOT NULL,
    PRIMARY KEY (snuuid, projid, tag),
    FOREIGN KEY (projid, snuuid) REFERENCES projects(projid, snuuid) MATCH FULL ON UPDATE CASCADE,
    FOREIGN KEY (tag) REFERENCES project_tags(tag) MATCH FULL ON UPDATE CASCADE
);
