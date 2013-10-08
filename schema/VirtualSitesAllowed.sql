-- Get the virtual sites allowed to this connection.

CREATE OR REPLACE VIEW virtual_sites_allowed AS

    SELECT
	snuuid,siteName,
        vsid,vsName

    FROM
        virtual_sites JOIN sites USING (snuuid)

    WHERE
        dbuser = current_user;

GRANT SELECT on virtual_sites_allowed TO hpcagent;
