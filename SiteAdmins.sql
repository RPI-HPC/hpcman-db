-- Define administrators of a site, and their permissions.

CREATE TABLE site_admins(
    snuuid BIGINT REFERENCES sites
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    puuid BIGINT REFERENCES principals
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    authid BIGINT,            -- Authenticator for administrative actions
    alterVSites BOOLEAN,      -- Permission to create, change VSites
    alterAdmins BOOLEAN,      -- Permission to create, change admins
    alterProjects BOOLEAN,    -- Permission to create, change projects
    alterUsers BOOLEAN,       -- Permission to create, change users
    alterGroups BOOLEAN,      -- Permission to create, change groups
    alterFilesystems BOOLEAN, -- Permission to create, change file systems
    PRIMARY KEY(snuuid,puuid),
    FOREIGN KEY (puuid,authid)
        REFERENCES authenticators(puuid,authid)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);
