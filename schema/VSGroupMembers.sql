-- Get group members associated with groups in a virtual site.

CREATE OR REPLACE VIEW vs_group_members AS

    SELECT

        snuuid,siteName,
        vsid,vsName,
        group_members.groupName AS groupName,
        userName,
        modified, userAccountState

    FROM

        ( (

            virtual_sites_allowed
            JOIN virtual_site_group_members USING(snuuid,vsid) )
            JOIN group_members USING(snuuid,groupName) )
            JOIN user_accounts USING(snuuid,userName) ;

GRANT SELECT on vs_group_members TO hpcagent;
