-- Define table for principals (people)

CREATE TABLE principals (
  puuid SERIAL,
  principalState char NOT NULL DEFAULT 'C',
  isVO boolean DEFAULT false,
  created timestamp with time zone NOT NULL DEFAULT now(),
  modified timestamp with time zone NOT NULL DEFAULT now(),
  expires timestamp with time zone,
  name varchar(60) NOT NULL,
  emailAddress varchar(60),
  contactInfo text,
  defaultUsername varchar(20),
  challengeword varchar(88),
  iuuid bigint, -- JPEG Image
  PRIMARY KEY (puuid),
  FOREIGN KEY (principalState) REFERENCES principalstates(principalstate),
  FOREIGN KEY (iuuid) REFERENCES images(iuuid)
);


-- Trigger to change modifed time on updates.

CREATE OR REPLACE FUNCTION
principals_set_modtime() RETURNS trigger AS $$
BEGIN
    NEW.modified = NOW();
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER principals_trigger_A_set_modtime
    BEFORE UPDATE
    ON principals
    FOR EACH ROW
        EXECUTE PROCEDURE principals_set_modtime();


-- Trigger to notify VSite agents.

-- FIXME: More fine grained: only hit affected sites.
CREATE OR REPLACE FUNCTION
principals_notify_vsite_agents() RETURNS trigger AS $$
BEGIN
    NOTIFY hpcman_site;
    RETURN NULL;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER principals_trigger_Z_notify_vsite_agents
    AFTER INSERT OR UPDATE OR DELETE
    ON principals
    FOR EACH ROW
        EXECUTE PROCEDURE principals_notify_vsite_agents();

