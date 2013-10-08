CREATE TABLE project_sponsors (
    snuuid bigint NOT NULL,
    projid bigint NOT NULL,
    puuid bigint NOT NULL,
    created timestamp without time zone DEFAULT now(),
    PRIMARY KEY (snuuid, projid, puuid),
    FOREIGN KEY (puuid) REFERENCES principals(puuid) MATCH FULL ON UPDATE CASCADE,
    FOREIGN KEY (snuuid, projid) REFERENCES projects(snuuid, projid) MATCH FULL ON UPDATE CASCADE
);
