-- File system quotas.

CREATE TABLE filesystem_user_quotas (
    snuuid bigint NOT NULL REFERENCES sites
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    fsName TEXT NOT NULL,
    userName VARCHAR(16) NOT NULL,
    softBlockQuota BIGINT,
    hardBlockQuota BIGINT,
    graceBlockQuota INTERVAL,
    softFileQuota BIGINT,
    hardFileQuota BIGINT,
    graceFileQuota INTERVAL,
    PRIMARY KEY (snuuid, fsName, userName),
    FOREIGN KEY (snuuid, fsName) REFERENCES filesystems(snuuid, fsName)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (snuuid, userName) REFERENCES user_accounts(snuuid, userName)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
