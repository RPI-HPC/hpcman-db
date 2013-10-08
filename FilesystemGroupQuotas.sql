-- File system quotas.

CREATE TABLE filesystem_group_quotas (
    snuuid bigint NOT NULL REFERENCES sites
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    fsName TEXT NOT NULL,
    groupName VARCHAR(16) NOT NULL,
    softBlockQuota BIGINT,
    hardBlockQuota BIGINT,
    graceBlockQuota INTERVAL,
    softFileQuota BIGINT,
    hardFileQuota BIGINT,
    graceFileQuota INTERVAL,
    PRIMARY KEY (snuuid, fsName, groupName),
    FOREIGN KEY (snuuid, fsName) REFERENCES filesystems(snuuid, fsName)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (snuuid, groupName) REFERENCES groups(snuuid, groupName)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
