-- Group definition information.

CREATE TABLE groups (
  snuuid bigint REFERENCES sites ON DELETE CASCADE,
  groupName varchar(16),
  gid smallint NOT NULL,
  description TEXT,
  groupState char(1) NOT NULL DEFAULT 'A'
      REFERENCES group_states,
  created timestamp with time zone DEFAULT NOW(),
  modified timestamp with time zone DEFAULT NOW(),
  PRIMARY KEY (snuuid, groupName),
  UNIQUE (snuuid, gid)
);

-- Trigger to make 'gid' be serial within a site.
--
-- FIXME: Skip past used gid's (in case of explicit settings).
-- FIXME: Allow randomization, for information hiding?

CREATE OR REPLACE FUNCTION
groups_set_gid() RETURNS trigger AS $$
BEGIN
    IF NEW.gid IS NULL THEN
        NEW.gid := nextval('site_'||NEW.snuuid||'_gid_seq');
    END IF;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER groups_trigger_A_set_gid
    BEFORE INSERT
    ON groups
    FOR EACH ROW
        EXECUTE PROCEDURE groups_set_gid();


-- Trigger to make sure we change the modified time on updates.
-- FIXME: Might want to make sure we really have interesting changes.

CREATE OR REPLACE FUNCTION
groups_set_modtime() RETURNS trigger AS $$
BEGIN
    NEW.modified = NOW();
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER groups_trigger_B_set_modtime
    BEFORE UPDATE
    ON groups
    FOR EACH ROW
        EXECUTE PROCEDURE groups_set_modtime();


-- Trigger to notify VSite agents.

-- FIXME: More fine grained: only hit affected sites.
CREATE OR REPLACE FUNCTION
groups_notify_vsite_agents() RETURNS trigger AS $$
BEGIN
    NOTIFY hpcman_site;
    RETURN NULL;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER groups_trigger_Z_notify_vsite_agents
    AFTER INSERT OR UPDATE OR DELETE
    ON groups
    FOR EACH ROW
        EXECUTE PROCEDURE groups_notify_vsite_agents();
