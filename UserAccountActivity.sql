-- Log when user accounts are active.

CREATE TABLE user_account_activity (
    recID BIGSERIAL,
    snuuid bigint NOT NULL REFERENCES sites
      ON DELETE CASCADE
      ON UPDATE CASCADE,
    userName varchar(16) NOT NULL,
    active TIMESTAMP WITH TIME ZONE NOT NULL,
    location TEXT NOT NULL,
    service TEXT NOT NULL,
    serviceData TEXT NOT NULL,
    PRIMARY KEY (recID),
    FOREIGN KEY (snuuid, userName) REFERENCES user_accounts(snuuid, userName),
    UNIQUE (snuuid, userName, active, location, service, serviceData)
);

-- Update the user_account table with active date.

CREATE OR REPLACE FUNCTION
user_accounts_set_active() RETURNS trigger AS $body$
DECLARE
    ua user_accounts%ROWTYPE;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        SELECT *
            INTO ua
            FROM user_accounts
            WHERE snuuid = NEW.snuuid AND userName = NEW.userName;
        IF (ua.lastActive IS NULL OR ua.lastActive < NEW.active) THEN
	    UPDATE user_accounts
                SET lastActive = NEW.active
                WHERE snuuid = NEW.snuuid AND userName = NEW.userName;
        END IF;
    END IF;
    RETURN NEW;
END
$body$ LANGUAGE plpgsql;

CREATE TRIGGER user_account_activity_trigger_A_set_active
    BEFORE INSERT
    ON user_account_activity
    FOR EACH ROW
        EXECUTE PROCEDURE user_accounts_set_active();
