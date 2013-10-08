-- Members of Virtual Sites.

-- FIXME: Need to handle groups, too.

CREATE TABLE virtual_site_members (
    snuuid bigint NOT NULL REFERENCES sites
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    vsid smallint,
    userName varchar(16) NOT NULL,
    PRIMARY KEY (snuuid, vsid, userName),
    FOREIGN KEY (snuuid, vsid) REFERENCES virtual_sites (snuuid, vsid)
        ON DELETE CASCADE,
    FOREIGN KEY (snuuid, userName) REFERENCES user_accounts (snuuid, userName)
        ON UPDATE CASCADE
);


-- Need an insert trigger to add all users to vsid 0.

CREATE OR REPLACE FUNCTION
user_accounts_add_vsid0() RETURNS trigger as $$
BEGIN
    INSERT INTO virtual_site_members (snuuid, vsid, userName)
        VALUES (NEW.snuuid, 0, NEW.userName);
    RETURN NULL;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_accounts_trigger_Z_add_vsid0
    AFTER INSERT
    ON user_accounts
    FOR EACH ROW
        EXECUTE PROCEDURE user_accounts_add_vsid0();
