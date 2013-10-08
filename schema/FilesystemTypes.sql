-- Types of file systems.

CREATE  TABLE filesystem_types (
    fsType TEXT PRIMARY KEY,
    fsTypeDescription TEXT
);


INSERT INTO filesystem_types
    VALUES
        ('GPFS', 'GPFS file system');

INSERT INTO filesystem_types
    VALUES
        ('GPFS-fileset', 'GPFS file set');
