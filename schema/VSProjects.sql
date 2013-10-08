-- Provide a view for agents that provision projects.

CREATE OR REPLACE VIEW vs_projects AS
    SELECT DISTINCT

        snuuid,siteName,
        vsid,vsName,
        projid,projName,projects.groupName AS projGroupName,
        projects.modified AS modified

    FROM

        ( (
            virtual_sites_allowed JOIN virtual_site_members
                USING(snuuid,vsid) )
            JOIN user_accounts USING(snuuid,userName) )
            JOIN projects USING(snuuid,projid);

GRANT SELECT on vs_projects TO hpcagent;
