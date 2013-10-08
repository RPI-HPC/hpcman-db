-- Projects.

CREATE TABLE projects (
    snuuid BIGINT REFERENCES sites
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    projid BIGINT,
    projName VARCHAR(16),
    projDesc TEXT,
    projShortDesc TEXT,
    projNotes TEXT,
    projSector char(1) NOT NULL DEFAULT 'A'
        REFERENCES projects_sectors,
    projField char(4)
        REFERENCES project_fields,
    projstate char(1) NOT NULL default 'E'
        REFERENCES project_states,
    projCPUQuota bigint NOT NULL DEFAULT 0,
    projUserName VARCHAR(16) DEFAULT 'dflt',
    groupName VARCHAR(16),
    created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    modified TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    PRIMARY KEY(snuuid, projid),
    UNIQUE(snuuid, projName),
    UNIQUE(snuuid, projUserName),
    FOREIGN KEY(snuuid,groupName) REFERENCES groups(snuuid,groupName)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);
-- QUESTION: Do we also want UNIQUE(snuuid, groupName)?  Seems less vital.

-- Trigger to change modified time on updates.

CREATE OR REPLACE FUNCTION
projects_set_modtime() RETURNS trigger AS $body$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        NEW.created = NOW();
        NEW.modified = NOW();
        IF NEW.projid IS NULL THEN
            NEW.projid := nextval('site_'||NEW.snuuid||'_projid_seq');
        END IF;
        IF NEW.groupName IS NULL THEN
            NEW.groupName = NEW.projName;
        END IF;
        -- FIXME: If the group already exists, don't create it!
        INSERT INTO groups (snuuid, groupName, description)
            VALUES(NEW.snuuid, NEW.groupName, NEW.projDesc);
    ELSE -- 'UPDATE'
        IF OLD.projid = 0 AND NEW.projid != 0 THEN
            RAISE EXCEPTION 'Can not change projid 0.';
        END IF;
        IF NEW.projid != OLD.projID OR
           NEW.projName != OLD.projName OR
           NEW.projDesc != OLD.projDesc OR
           NEW.projCPUQuota != OLD.projCPUQuota OR
           NEW.projSector != OLD.projSector OR
           NEW.groupName != OLD.groupName THEN
            NEW.modified = NOW();
        END IF;
    END IF;
    RETURN NEW;
END
$body$ LANGUAGE plpgsql;

CREATE TRIGGER projects_trigger_A_set_modtime
    BEFORE INSERT OR UPDATE
    ON projects
    FOR EACH ROW
        EXECUTE PROCEDURE projects_set_modtime();


-- Trigger to create projid 0 on new sites.
-- This is on the sites table.

CREATE OR REPLACE FUNCTION
sites_create_projid0() RETURNS trigger AS $body$
BEGIN
    INSERT INTO projects (snuuid, projid, projName, projUserName, projDesc)
        VALUES (NEW.snuuid, 0, 'users', 'user', 'All users');
--    INSERT INTO groups (snuuid, groupname, description)
--	VALUES (NEW.snuuid, 'default', 'Users of default group');
    RETURN NULL;
END
$body$ LANGUAGE plpgsql;

CREATE TRIGGER sites_trigger_C_create_projid0
    AFTER INSERT
    ON sites
    FOR EACH ROW
        EXECUTE PROCEDURE sites_create_projid0();
