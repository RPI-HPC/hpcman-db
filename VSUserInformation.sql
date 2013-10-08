-- Provide a view for agents that change passwords.

-- The agent's DB user must be a member of the hpcpasswdadmin group,
-- and access to the appropriate virtual sites granted to that user
-- through the virtual_sites_allowed table.

-- The result should provide enough information to allow the
-- appropriate puuid,authid pair to be selected, which in turn selects
-- authenticators, as well as being part of the key to passwords.
-- Note that more than one user account may use the same
-- authenticator, in which case changing associated passwords will
-- affect each such account.


CREATE OR REPLACE VIEW vs_user_information AS
    SELECT

        snuuid,siteName,
        vsid,vsName,useraccountstate,
        puuid,name,emailAddress,contactInfo,
        projid,projName,userName,authid,authname

    FROM

        ( ( ( (
            virtual_sites_allowed JOIN virtual_site_members
                USING(snuuid,vsid) )
            JOIN user_accounts USING(snuuid,userName) )
            JOIN principals USING(puuid) )
            JOIN authenticators USING(puuid,authid) )
            JOIN projects USING(snuuid,projid);

GRANT SELECT on vs_user_information TO vspasswdadmin;
