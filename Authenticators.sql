-- Named authenticators.

CREATE TABLE authenticators (
    puuid BIGINT NOT NULL REFERENCES principals
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    authid BIGINT NOT NULL DEFAULT 0,
    authname TEXT NOT NULL DEFAULT 'default',
    mustChange BOOLEAN NOT NULL DEFAULT 't',
    created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    modified TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    PRIMARY KEY (puuid, authid),
    UNIQUE (puuid, authname)
);


-- Trigger to change modifed time on updates.

CREATE OR REPLACE FUNCTION
authenticators_set_modtime() RETURNS trigger AS $body$
BEGIN
    IF (TG_OP = 'INSERT') THEN
	NEW.created = NOW();
        NEW.modified = NOW();
    ELSE -- 'UPDATE'
        IF (OLD.authid = 0 AND NEW.authid != 0) THEN
            RAISE EXCEPTION 'Can not change authid 0';
        END IF;
        -- If there were anything we cared about, check modified.
    END IF;
    RETURN NEW;
END
$body$ LANGUAGE plpgsql;

CREATE TRIGGER authenticators_trigger_A_set_modtime
    BEFORE INSERT OR UPDATE
    ON authenticators
    FOR EACH ROW
        EXECUTE PROCEDURE authenticators_set_modtime();


-- Create a default authenticator for each principal.
-- This will be a trigger on the "principals" table.

CREATE OR REPLACE FUNCTION
principal_create_authenticator() RETURNS trigger AS $body$
BEGIN
    INSERT INTO authenticators
        VALUES(NEW.puuid);
    RETURN NEW;
END
$body$ LANGUAGE plpgsql;

CREATE TRIGGER principal_trigger_B_create_authenticator
    AFTER INSERT
    ON principals
    FOR EACH ROW
        EXECUTE PROCEDURE principal_create_authenticator();
