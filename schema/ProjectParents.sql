/*	Store relations between projects and projects that control projects.
	Initially intended to be 1:1, this could change.
*/

CREATE TABLE project_parents (
    snuuid BIGINT REFERENCES sites
        ON DELETE CASCADE
	ON UPDATE CASCADE,
    projid BIGINT NOT NULL,
    projparentid BIGINT NOT NULL CHECK (projid <> projparentid),
    parentShare FLOAT NOT NULL DEFAULT 1.0 
    	CHECK (parentShare <= 1.0)
	CHECK (parentShare > 0),
    created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    modified TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Check that inserts and updates do not cause a > 1.0
CREATE OR REPLACE RULE project_hierarchy_sum_insert
	AS ON INSERT TO project_parents
	WHERE (SELECT sum(parentShare)
		FROM project_parents
		WHERE snuuid=NEW.snuuid
		AND projid=NEW.projid) + NEW.parentShare > 1.0
	DO INSTEAD NOTHING;

CREATE OR REPLACE RULE project_hierarchy_sum_update
        AS ON UPDATE TO project_parents
	WHERE (SELECT sum(parentShare)
	        FROM project_parents
		WHERE snuuid=NEW.snuuid
		AND projid=NEW.projid
		AND projparentid <> NEW.projparentid) + NEW.parentShare > 1.0
	DO INSTEAD NOTHING;

-- Check for exactly one project and one project parent
CREATE OR REPLACE RULE project_hierarchy_refint
	AS ON INSERT TO project_parents
	WHERE (SELECT count(projid) FROM projects WHERE
		projid = NEW.projid AND snuuid = NEW.snuuid)
	+ (SELECT count(projid) FROM projects WHERE
                projid = NEW.projparentid AND snuuid = NEW.snuuid)
	<> 2
	DO INSTEAD NOTHING;
