-- Provide a view for agents that must manipulate /etc/passwd information.

-- FIXME: Should return email, authid, persid, and their names.
-- FIXME: Do something similar with groups.
--        Groups can belong to a vsid.  But we also need to include any
--        group named as the default group for a user in the vsid, e.g.,
--        the "users" group.

CREATE OR REPLACE FUNCTION
choose_string(a TEXT, b TEXT)
RETURNS TEXT AS $body$
BEGIN
    IF a IS NULL THEN
        RETURN b;
    ELSIF a = '' THEN
        RETURN b;
    ELSE
        RETURN a;
    END IF;
END;
$body$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE VIEW vs_user_accounts AS
    SELECT

        snuuid,siteName,
        vsid,vsName,
        uid,userName,
        gid,user_accounts.groupName AS groupName,
        password,passwordType,mustChange AS passwordMustChange,
        choose_string(fullname,name) AS name,
        shell,
        homeDirectory,
        quota,
        userAccountState,
        projid,projName,projects.groupName AS projGroupName,
	GREATEST(user_accounts.modified,
                 groups.modified,
                 principals.modified,
                 personae.modified,
                 authenticators.modified,
                 passwords.modified,
                 projects.modified) AS modified,
        lastActive,
        user_accounts.created AS created

    FROM

        ( ( ( ( ( ( (
            virtual_sites_allowed JOIN virtual_site_members
                USING(snuuid,vsid) )
            JOIN user_accounts USING(snuuid,userName) )
            JOIN groups USING(snuuid,groupName) )
            JOIN principals USING(puuid) )
            JOIN personae USING(puuid,persid) )
            JOIN authenticators USING(puuid,authid) )
            JOIN passwords USING(puuid,authid) )
            JOIN projects USING(snuuid,projid);

GRANT SELECT on vs_user_accounts TO hpcagent;
