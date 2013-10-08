
/*
-- Rule to setup default group for default projects
CREATE OR REPLACE RULE create_project_group_default
        AS ON INSERT TO projects
        DO ALSO
                INSERT INTO groups (
                groupname, snuuid
                ) VALUES (
                'dflt',
                NEW.snuuid
);
*/
-- Rule to setup default group for non-default projects
CREATE OR REPLACE RULE create_project_group
        AS ON INSERT TO projects
	WHERE NEW.projname <> 'default'
        DO ALSO
                INSERT INTO groups (
                groupname, snuuid
                ) VALUES (
                NEW.groupname,
                NEW.snuuid
);

-- Rule to update default group
CREATE OR REPLACE RULE update_project_group
         AS ON UPDATE TO projects
         DO ALSO
                UPDATE groups
                SET groupname=NEW.groupname
                WHERE
                snuuid=NEW.snuuid
                AND groupname=OLD.groupname
;
