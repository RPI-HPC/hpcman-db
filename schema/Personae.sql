-- Personae: Define personae for a principal.  Allow a principal to
-- choose which persona is used with an account.

CREATE TABLE personae (
    puuid BIGINT NOT NULL REFERENCES principals
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    persid BIGINT NOT NULL DEFAULT 0,
    persname TEXT NOT NULL DEFAULT 'default',
    fullname TEXT,
    emailAddress TEXT,
    created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    modified TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    PRIMARY KEY (puuid, persid),
    UNIQUE (puuid, persname),
    CHECK (persid = 0 OR fullname IS NOT NULL),
    CHECK (persid = 0 OR emailAddress IS NOT NULL)
);

-- FIXME: Prevent deletion of persid=0 records, unless this is a cascade
--        delete of principal.  (Or maybe force deletion of principal?)



-- Trigger to change modifed time on updates, and to notify
-- VSite agents.
-- FIXME: More fine grained control of notifying agents.

CREATE OR REPLACE FUNCTION
personae_set_modtime() RETURNS trigger AS $body$
BEGIN
    IF (TG_OP = 'INSERT') THEN
	NEW.created = NOW();
        NEW.modified = NOW();
        NOTIFY hpcman_site;
    ELSE -- 'UPDATE'
        IF (OLD.persid = 0 AND NEW.persid != 0) THEN
            RAISE EXCEPTION 'Can not change persid 0';
        END IF;
        IF (NEW.fullname != OLD.fullname OR
            NEW.emailAddress != OLD.emailAddress) THEN
            NEW.modified = NOW();
           NOTIFY hpcman_site;
        END IF;
    END IF;
    RETURN NEW;
END
$body$ LANGUAGE plpgsql;

CREATE TRIGGER personae_trigger_A_set_modtime
    BEFORE INSERT OR UPDATE
    ON personae
    FOR EACH ROW
        EXECUTE PROCEDURE personae_set_modtime();


-- Create a default persona for each principal.
-- This will be a trigger on the "principals" table.

CREATE OR REPLACE FUNCTION
principal_create_persona() RETURNS trigger AS $body$
BEGIN
    INSERT INTO personae (puuid)
        VALUES(NEW.puuid);
    RETURN NEW;
END
$body$ LANGUAGE plpgsql;

CREATE TRIGGER principal_trigger_B_create_persona
    AFTER INSERT
    ON principals
    FOR EACH ROW
        EXECUTE PROCEDURE principal_create_persona();
