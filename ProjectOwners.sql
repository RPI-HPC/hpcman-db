-- Owners of projects.

CREATE TABLE project_owners (
    snuuid BIGINT REFERENCES sites
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    projid BIGINT,
    puuid BIGINT REFERENCES principals
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    modified TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    PRIMARY KEY(snuuid, projid, puuid),
    FOREIGN KEY (puuid) REFERENCES principals(puuid) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (snuuid, projid) REFERENCES projects(snuuid, projid) ON UPDATE CASCADE ON DELETE CASCADE
);
