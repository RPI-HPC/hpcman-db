-- Store data about sites
--
-- Each site has site uuid, 'snuuid'.  This permits sites to be renamed.
-- Tables should reference the snuuid instead of the site name.
--
-- When groups and accounts are created, the corresponding gids and uids
-- are counted from a startGid and startUid, respectively.
-- FIXME: Randomize computing gid and uid.
-- FIXME: Handle a used gid, uid.
-- FIXME: Reserved groups, users.
--
-- A site might have multiple "virtual sites".  VSID 0 is everything in the
-- site.  By default it is named 'universe', but it can be renamed for a site.
--
-- Within a site, each virtual site has a database user for agents that need
-- to read information.  This includes the 'universe' virtual site.  By
-- default this will be the current_user, but another user may be specified.

CREATE TABLE sites (
  snuuid SERIAL,
  siteName VARCHAR(100) NOT NULL UNIQUE,
  description TEXT NOT NULL,
  startUid SMALLINT DEFAULT(1000),
  startGid SMALLINT DEFAULT(1000),
  defaultShell TEXT NOT NULL,
  universeName varchar(100) NOT NULL DEFAULT 'universe',
  uvUser varchar(16) NOT NULL DEFAULT current_user,
  created TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  modified TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  PRIMARY KEY (snuuid)
);

-- Trigger to make 'gid' and 'uid' sequences specific to the site.
-- Also start vsid sequence, and vsid 0.
-- Also start projid sequence, and projid 0.

CREATE OR REPLACE FUNCTION
make_site_sequences() RETURNS trigger AS $$
BEGIN
    EXECUTE 'CREATE SEQUENCE site_' || NEW.snuuid || '_uid_seq MINVALUE ' || NEW.startUid;
    EXECUTE 'CREATE SEQUENCE site_' || NEW.snuuid || '_gid_seq MINVALUE ' || NEW.startGid;
    EXECUTE 'CREATE SEQUENCE site_' || NEW.snuuid || '_vsid_seq MINVALUE 1';
    EXECUTE 'CREATE SEQUENCE site_' || NEW.snuuid || '_projid_seq MINVALUE 1';
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER make_site_sequences_trigger
    AFTER INSERT
    ON sites
    FOR EACH ROW
        EXECUTE PROCEDURE make_site_sequences();


-- Trigger to delete 'gid' and 'uid' sequences specific to the site.

CREATE OR REPLACE FUNCTION
delete_site_sequences() RETURNS TRIGGER AS $$
BEGIN
    EXECUTE 'DROP SEQUENCE site_' || OLD.snuuid || '_uid_seq';
    EXECUTE 'DROP SEQUENCE site_' || OLD.snuuid || '_gid_seq';
    EXECUTE 'DROP SEQUENCE site_' || OLD.snuuid || '_vsid_seq';
    EXECUTE 'DROP SEQUENCE site_' || OLD.snuuid || '_projid_seq';
    RETURN NULL;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_site_sequences_trigger
    AFTER DELETE
    ON sites
    FOR EACH ROW
        EXECUTE PROCEDURE delete_site_sequences();


-- Trigger to make sure we change the modified time on updates.

CREATE OR REPLACE FUNCTION
sites_set_modtime() RETURNS trigger AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        NEW.modified = NOW();
    ELSE
        IF (NEW.snuuid != OLD.snuuid
            OR NEW.created != OLD.created) THEN
            RETURN NULL;
        END IF;
        IF (NEW.siteName != OLD.siteName
            OR NEW.description != OLD.description
            OR NEW.startUid != OLD.startUid
            OR NEW.startGid != OLD.startGid
            OR NEW.universeName != OLD.universeName
            OR NEW.uvUser != OLD.uvUser) THEN
            NEW.modified = NOW();
        END IF;
    END IF;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER sites_trigger_B_set_modtime
    BEFORE UPDATE
    ON sites
    FOR EACH ROW
        EXECUTE PROCEDURE sites_set_modtime();
