-- Provide a view for agents that must manipulate /etc/group information.

-- FIXME: Need an aggregate on groupState.  Active users on a disabled group
-- should be handled; right now, we'll have two rows returned, and confusion.

CREATE OR REPLACE VIEW vs_groups AS
    SELECT

        snuuid,siteName,
        vsid,vsName,
        gid,groupName,
        MAX(modified) AS modified,
        groupState

    FROM

        ( -- Get all the groups
            -- First, default groups of users
            ( SELECT DISTINCT
                    snuuid,
                    vsid,
                    groupName,
                    gid,
                    max_time(user_accounts.modified,
                             groups.modified) AS modified,
                    userAccountState AS groupState
                FROM ( (
                    user_accounts JOIN virtual_site_members
                        USING(snuuid,userName) )
                    JOIN groups USING(snuuid,groupName) )
                WHERE
                   userAccountState = 'A'
            )
            UNION
            -- Second, the explict groups.
            ( SELECT DISTINCT
                    snuuid,
                    vsid,
                    groupName,
                    gid,
                    modified,
                    groupState
                FROM groups JOIN virtual_site_group_members
                    USING(snuuid,groupName))

        ) AS allgroups
        JOIN virtual_sites_allowed USING(snuuid,vsid)

    GROUP BY snuuid,siteName,vsid,vsName,groupName,gid,groupState;


GRANT SELECT on vs_groups TO hpcagent;
