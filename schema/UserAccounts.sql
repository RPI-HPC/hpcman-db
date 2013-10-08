-- User account information.

CREATE TABLE user_accounts (
    snuuid bigint NOT NULL REFERENCES sites
      ON DELETE CASCADE
      ON UPDATE CASCADE,
    userName varchar(16) NOT NULL,
    puuid bigint NOT NULL REFERENCES principals
      ON DELETE RESTRICT
      ON UPDATE CASCADE,
    authid BIGINT NOT NULL DEFAULT 0,
    persid BIGINT NOT NULL DEFAULT 0,
    projid BIGINT NOT NULL, 
    uid smallint NOT NULL,
    groupName varchar(16),
    homeDirectory varchar(60) DEFAULT '/var/empty' NOT NULL,
    quota bigint,
    shell varchar(60) DEFAULT '/bin/false' NOT NULL,
    userAccountState char(1) NOT NULL DEFAULT 'A'
        REFERENCES user_accounts_states,
    created TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    modified TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    lastActive TIMESTAMP WITH TIME ZONE,
    PRIMARY KEY (snuuid, userName),
    FOREIGN KEY (snuuid, groupName) REFERENCES groups(snuuid, groupName)
        ON UPDATE CASCADE,
    FOREIGN KEY (snuuid,projid) REFERENCES projects(snuuid,projid)
        ON UPDATE CASCADE,
    UNIQUE (snuuid, userName),
    UNIQUE (snuuid, uid)
);

-- Trigger to make 'uid' be serial within a site.
--
-- FIXME: Skip past used uid's (in case of explicit settings).
-- FIXME: Allow randomization, for information hiding?

CREATE OR REPLACE FUNCTION
user_accounts_set_uid() RETURNS trigger AS $body$
BEGIN
    IF NEW.uid IS NULL THEN
        NEW.uid := nextval('site_'||NEW.snuuid||'_uid_seq');
    END IF;
    RETURN NEW;
END
$body$ LANGUAGE plpgsql;

CREATE TRIGGER user_accounts_trigger_A_set_uid
    BEFORE INSERT OR UPDATE
    ON user_accounts
    FOR EACH ROW
        EXECUTE PROCEDURE user_accounts_set_uid();

-- Trigger to set groupName from project.

CREATE OR REPLACE FUNCTION
user_accounts_set_groupName() RETURNS trigger AS $$
DECLARE
    proj_row projects%ROWTYPE;
BEGIN
    IF (NEW.groupName IS NULL) THEN
        SELECT *
            INTO proj_row
            FROM projects
            WHERE
                snuuid = NEW.snuuid AND projid = NEW.projid;
        NEW.groupName = proj_row.groupName;
    END IF;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_accounts_trigger_B_set_groupName
    BEFORE INSERT OR UPDATE
    ON user_accounts
    FOR EACH ROW
        EXECUTE PROCEDURE user_accounts_set_groupName();


-- Trigger to make sure we change the modified time on updates.
-- FIXME: Might want to make sure we really have interesting changes.

CREATE OR REPLACE FUNCTION
user_accounts_set_modtime() RETURNS trigger AS $$
BEGIN
    NEW.modified = NOW();
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_accounts_trigger_C_set_modtime
    BEFORE UPDATE
    ON user_accounts
    FOR EACH ROW
        EXECUTE PROCEDURE user_accounts_set_modtime();


-- Trigger to notify VSite agents.

-- FIXME: More fine grained: only hit affected sites.
CREATE OR REPLACE FUNCTION
user_accounts_notify_vsite_agents() RETURNS trigger AS $$
BEGIN
    NOTIFY hpcman_site;
    RETURN NULL;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_accounts_trigger_Z_notify_vsite_agents
    AFTER INSERT OR UPDATE OR DELETE
    ON user_accounts
    FOR EACH ROW
        EXECUTE PROCEDURE user_accounts_notify_vsite_agents();
