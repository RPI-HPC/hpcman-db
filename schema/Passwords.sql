-- Password hashes for principals.

CREATE TABLE passwords (
    puuid BIGINT NOT NULL REFERENCES principals
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    authid BIGINT NOT NULL DEFAULT 0,
    passwordType TEXT REFERENCES password_types
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    password TEXT,
    created TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    modified TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    PRIMARY KEY (puuid, authid, passwordType)
);


-- Trigger to make sure we change the modified time on updates, and to
-- notify VSite agents.
-- FIXME: More fine grained control of notifying agents.

CREATE OR REPLACE FUNCTION
passwords_set_modtime() RETURNS trigger AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        NEW.modified = NOW();
	NOTIFY hpcman_site;
    ELSE
        IF (NEW.password != OLD.password) THEN
            NEW.modified = NOW();
            NOTIFY hpcman_site;
        END IF;
    END IF;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER passwords_trigger_B_set_modtime
    BEFORE INSERT OR UPDATE
    ON passwords
    FOR EACH ROW
        EXECUTE PROCEDURE passwords_set_modtime();

