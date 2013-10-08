-- Sector for projects.

CREATE TABLE projects_sectors (
    projectSector char(1) PRIMARY KEY,
    projectSectorDesc text NOT NULL
);

INSERT INTO projects_sectors
    VALUES
        ('A', 'Academic');
INSERT INTO projects_sectors
    VALUES
        ('C', 'Commercial');
INSERT INTO projects_sectors
    VALUES
        ('G', 'Government');
