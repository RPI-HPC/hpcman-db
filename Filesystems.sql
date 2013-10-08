-- File System information.

CREATE TABLE filesystems (
    snuuid bigint NOT NULL        -- Site holding this file system.
        REFERENCES sites
          ON DELETE CASCADE
          ON UPDATE CASCADE,
    fsName TEXT NOT NULL,         -- Name of file system, within site.
    fsType TEXT NOT NULL          -- Type of file system.
        REFERENCES filesystem_types,
    description TEXT,             -- What is the purpose, owner, etc.?
    devID TEXT,                   -- Device, dev+fileset, etc.
    mountPoint TEXT NOT NULL,     -- Where mounted?
    created TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    blocksize integer,
    PRIMARY KEY (snuuid, fsName)
);
