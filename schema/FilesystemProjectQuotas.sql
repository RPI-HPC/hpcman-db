-- File system quotas.

CREATE TABLE filesystem_project_quotas (
    snuuid bigint NOT NULL REFERENCES sites
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    fsName TEXT NOT NULL,
    projid BIGINT NOT NULL,
    softBlockQuota BIGINT,
    hardBlockQuota BIGINT,
    graceBlockQuota INTERVAL,
    softFileQuota BIGINT,
    hardFileQuota BIGINT,
    graceFileQuota INTERVAL,
    blockusage bigint,
    created timestamp with time zone not null default NOW(),
    modified timestamp with time zone not null default NOW(),
    changed timestamp with time zone,
    refreshed timestamp with time zone,
    PRIMARY KEY (snuuid, fsName, projid),
    FOREIGN KEY (snuuid, fsName) REFERENCES filesystems(snuuid, fsName)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (snuuid, projid) REFERENCES projects(snuuid, projid)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE OR REPLACE FUNCTION
filesystem_quota_set_updatetime() RETURNS trigger AS $body$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        IF (NEW.blockusage <> OLD.blockusage) THEN
            NEW.changed = NOW();
        END IF;

        IF (NEW.blockusage IS NOT NULL) THEN
            NEW.refreshed = NOW();
        END IF;

        IF (NEW.hardBlockQuota <> OLD.hardBlockQuota OR NEW.softBlockQuota <> OLD.softBlockQuota) THEN
            NEW.modified = NOW();
        END IF;
    END IF;
    RETURN NEW;
END
$body$ LANGUAGE plpgsql;

CREATE TRIGGER filesystem_projects_quota_a_filesystem_quota_set_updatetime
    BEFORE UPDATE
    ON filesystem_project_quotas
    FOR EACH ROW
        EXECUTE PROCEDURE filesystem_quota_set_updatetime();
