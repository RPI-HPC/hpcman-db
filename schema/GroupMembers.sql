-- Group memberships.

CREATE TABLE group_members (
  snuuid bigint REFERENCES sites ON DELETE CASCADE,
  groupName varchar(16),
  userName varchar(16),
  creation timestamp with time zone DEFAULT NOW(),
  PRIMARY KEY (snuuid, groupName, userName),
  FOREIGN KEY (snuuid, userName)
      REFERENCES user_accounts (snuuid, userName)
      ON DELETE CASCADE
      ON UPDATE CASCADE,
  FOREIGN KEY (snuuid, groupName) REFERENCES groups (snuuid, groupName)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);


-- Triggers to make a group 'change' if its membership changes.

CREATE OR REPLACE FUNCTION
group_set_modtime_member() RETURNS trigger AS $$
DECLARE
    ksnuuid bigint;
    kgroupName varchar(16);
BEGIN
    IF (TG_OP = 'INSERT') THEN
        ksnuuid := NEW.snuuid;
        kgroupName := NEW.groupName;
    ELSE
        ksnuuid := OLD.snuuid;
        kgroupName := OLD.groupName;
    END IF;
    UPDATE groups
        SET modified = now()
        WHERE snuuid = ksnuuid AND groupName = kgroupName;
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        RETURN NEW;
    ELSE
        RETURN OLD;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER groups_trigger_C_set_modtime_member
    BEFORE INSERT OR UPDATE OR DELETE
    ON group_members
    FOR EACH ROW
        EXECUTE PROCEDURE group_set_modtime_member();
