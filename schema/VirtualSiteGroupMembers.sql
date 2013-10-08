-- Groups that are members of Virtual Sites.

CREATE TABLE virtual_site_group_members (
    snuuid bigint NOT NULL REFERENCES sites
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    vsid smallint,
    groupName varchar(16) NOT NULL,
    PRIMARY KEY (snuuid, vsid, groupName),
    FOREIGN KEY (snuuid, vsid) REFERENCES virtual_sites (snuuid, vsid)
        ON DELETE CASCADE,
    FOREIGN KEY (snuuid, groupName) REFERENCES groups (snuuid, groupName)
        ON UPDATE CASCADE
);


-- Need an insert trigger to add all groups to vsid 0.

CREATE OR REPLACE FUNCTION
groups_add_vsid0() RETURNS trigger as $$
BEGIN
    INSERT INTO virtual_site_group_members (snuuid, vsid, groupName)
        VALUES (NEW.snuuid, 0, NEW.groupName);
    RETURN NULL;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER groups_trigger_Z_add_vsid0
    AFTER INSERT
    ON groups
    FOR EACH ROW
        EXECUTE PROCEDURE groups_add_vsid0();
