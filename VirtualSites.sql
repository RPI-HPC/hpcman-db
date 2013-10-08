-- Virtual Sites

-- A virtual site models a subset of a site.  Agents associated with a
-- particular virtual site will only have access to user information
-- associated with that virtual site.


CREATE TABLE virtual_sites (
    snuuid BIGINT REFERENCES sites
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    vsid SMALLINT NOT NULL,
    dbuser VARCHAR(16) NOT NULL,
    vsName VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    created TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    modified TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    PRIMARY KEY(snuuid, vsid),
    UNIQUE(snuuid,vsName)
);

-- Trigger to make 'vsid' be serial within a site.
-- Always the case that vsid=0 will refer to all entities within site.

CREATE OR REPLACE FUNCTION
virtual_sites_set_vsid() RETURNS trigger AS $body$
BEGIN
    IF NEW.vsid IS NULL THEN
        NEW.vsid := nextval('site_'||NEW.snuuid||'_vsid_seq');
    END IF;
    RETURN NEW;
END
$body$ LANGUAGE plpgsql;

CREATE TRIGGER virtual_sites_trigger_A_set_vsid
    BEFORE INSERT
    ON virtual_sites
    FOR EACH ROW
        EXECUTE PROCEDURE virtual_sites_set_vsid();


-- Trigger to make vsid 0 whenever a site is created.
-- This is on the sites table.

CREATE OR REPLACE FUNCTION
sites_create_vsid0() RETURNS trigger AS $body$
BEGIN
    INSERT INTO virtual_sites (snuuid, vsid, dbuser, vsName, description)
        VALUES(NEW.snuuid, 0, NEW.uvUser, NEW.universeName, NEW.description);
    RETURN NULL;
END;
$body$ LANGUAGE plpgsql;

CREATE TRIGGER sites_trigger_B_create_vsid0
    AFTER INSERT
    ON sites
    FOR EACH ROW
        EXECUTE PROCEDURE sites_create_vsid0();


-- Trigger to update vsid 0 if the site is modified.
-- This is on the sites table.

CREATE OR REPLACE FUNCTION
sites_modify_vsid0() RETURNS trigger AS $body$
BEGIN
    UPDATE virtual_sites
        SET
            dbuser = NEW.uvUser,
            vsName = NEW.universeName,
            description = NEW.description
        WHERE snuuid=NEW.snuuid AND vsid=0;
    RETURN NULL;
END;
$body$ LANGUAGE plpgsql;

CREATE TRIGGER sites_trigger_B_modify_vsid0
    AFTER UPDATE
    ON sites
    FOR EACH ROW
        EXECUTE PROCEDURE sites_modify_vsid0();


-- Trigger to updates sites if vsid 0 is modified.

CREATE OR REPLACE FUNCTION
virtual_sites_follow_vsid0() RETURNS trigger AS $body$
BEGIN
    IF (NEW.vsid = 0 AND (
            NEW.dbuser != OLD.dbuser
            OR NEW.vsName != OLD.vsName
            OR NEW.description != OLD.description)) THEN
        UPDATE sites
            SET
                universeName = NEW.vsName,
                uvUser = NEW.dbuser,
                description = NEW.description
            WHERE
                snuuid = NEW.snuuid;
    END IF;
    RETURN NULL;
END
$body$ LANGUAGE plpgsql;

CREATE TRIGGER virtual_sites_trigger_C_follow_vsid0
    AFTER UPDATE
    ON virtual_sites
    FOR EACH ROW
        EXECUTE PROCEDURE virtual_sites_follow_vsid0();


-- Trigger to make sure we change the modified time on updates.
-- Veto changing the vsid.

CREATE OR REPLACE FUNCTION
virtual_sites_set_modtime() RETURNS trigger AS $body$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        NEW.modified = NOW();
    ELSE
        IF (NEW.vsid != OLD.vsid
            OR NEW.created != OLD.created) THEN
            RETURN NULL;
        END IF;
        IF (NEW.snuuid != OLD.snuuid
           OR NEW.vsid != OLD.vsid
           OR NEW.dbuser != OLD.dbuser
           OR NEW.vsName != OLD.vsName
           OR NEW.description != OLD.description) THEN
            NEW.modified = NOW();
        END IF;
    END IF;
    RETURN NEW;
END
$body$ LANGUAGE plpgsql;

CREATE TRIGGER virtual_sites_trigger_C_set_modtime
    BEFORE UPDATE OR INSERT
    ON virtual_sites
    FOR EACH ROW
        EXECUTE PROCEDURE virtual_sites_set_modtime();
