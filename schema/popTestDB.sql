-- Add a role for agents.
DROP ROLE toysagent, workagent, secretagent;
CREATE USER toysagent IN GROUP hpcagent;
CREATE USER workagent IN GROUP hpcagent;
CREATE USER secretagent IN GROUP hpcagent;

-- Some images

INSERT INTO images (
	image_name, image_type, image_blob
) VALUES (
	'Random User', 'jpg', NULL
);

INSERT INTO images (
	image_name, image_type, image_blob
) VALUES (
	'Smart Guy', 'jpg', NULL
);

-- Some principals.


INSERT INTO principals (
	name, contactInfo, defaultUserName, iuuid
) VALUES (
	'Random User', 'userr@rpi.org', 'userr', 1
), (
	'Smart Guy', 'smarty@rpi.org', 'smarty', 1
), (
	'Joe Smith', 'smithj@rpi.org', 'smithj', 1
);
--INSERT INTO passwords (
--        puuid, passwordType, password
--) SELECT puuid, 'cleartext', 'squeak' FROM principals
--  WHERE name = 'Random User';
INSERT INTO passwords ( -- 'squeak'
        puuid, passwordType, password
) SELECT puuid, 'ssha', '4oH2KArhxD9CqgmyA0dm0e+7hATp/+/Z' FROM principals
  WHERE name = 'Random User';
--INSERT INTO passwords (
--        puuid, passwordType, password
--) SELECT puuid, 'cleartext', 'forgot' FROM principals
--  WHERE name = 'Smart Guy';
INSERT INTO passwords ( -- 'forgot'
        puuid, passwordType, password
) SELECT puuid, 'ssha', '8vqFFWtJFyQPLEP78kVJSnLPGpC8/kqG' FROM principals
  WHERE name = 'Smart Guy';
INSERT INTO passwords (
        puuid, passwordType, password
) SELECT puuid, 'cleartext', 'pound' FROM principals
  WHERE name = 'Joe Smith';


-- Some sites

INSERT INTO sites (siteName, description, defaultShell, uvUser)
    VALUES ('toys', 'Playground site', '/bin/bash', 'toysagent');
INSERT INTO sites (siteName, description, defaultShell, uvUser)
    VALUES ('work', 'Real work site', '/bin/tcsh', 'workagent');
INSERT INTO sites (siteName, description, defaultShell)
    VALUES ('test', 'A site for testing', '/bin/bash');

-- A virtual site, associated with 'test' site.
INSERT INTO virtual_sites (snuuid, dbUser, vsName, description)
    SELECT snuuid, 'secretagent', 'secret', 'Hush hush!'
        FROM sites
        WHERE siteName='test';

-- Some sponsors

INSERT INTO sponsors (
	snuuid, puuid, spuuid, expires, state
) SELECT snuuid, puuid, puuid, now()+'1 year', 'A'
	FROM sites, principals
	WHERE siteName='toys' and  name='Random User';

INSERT INTO sponsors (
	snuuid, puuid, spuuid, expires, state
) SELECT snuuid, puuid, puuid, now()+'1 year', 'A'
	FROM sites, principals
	WHERE siteName='work' and  name='Smart Guy';

-- Some projects

INSERT INTO projects (projName, projDesc, projUserName, snuuid)
    SELECT  'toyusers', 'Users of toys', 'easy', snuuid
        FROM sites
        WHERE siteName='toys';

INSERT INTO projects (projName, projDesc, projUserName, snuuid)
    SELECT  'workers', 'Hard workers', 'hard', snuuid
        FROM sites
        WHERE siteName='work';

INSERT INTO projects (projName, projDesc, projUserName, snuuid)
    SELECT  'guineapigs', 'Test subjects', 'test', snuuid
        FROM sites
        WHERE siteName='test';


-- Some groups

/*
INSERT INTO groups (
	snuuid, groupName
) SELECT snuuid, 'users'
	FROM sites
	WHERE siteName='work';
*/

INSERT INTO groups (
	snuuid, groupName
) SELECT snuuid, 'progs'
	FROM sites
	WHERE siteName='work';

/*
INSERT INTO groups (
	snuuid, groupName
) SELECT snuuid, 'users'
	FROM sites
	WHERE siteName='toys';
*/

INSERT INTO groups (
	snuuid, groupName
) SELECT snuuid, 'admins'
	FROM sites
	WHERE siteName='toys';

/*
INSERT INTO groups (
	snuuid, groupName
) SELECT snuuid, 'users'
	FROM sites
	WHERE siteName='test';
*/

INSERT INTO groups (
	snuuid, groupName
) SELECT snuuid, 'admins'
	FROM sites
	WHERE siteName='test';

INSERT INTO groups (
	snuuid, groupName
) SELECT snuuid, 'progs'
	FROM sites
	WHERE siteName='test';

INSERT INTO groups (
	snuuid, groupName
) SELECT snuuid, 'secret'
	FROM sites
	WHERE siteName='test';


-- Now some user accounts

INSERT INTO user_accounts (
	puuid, userName, snuuid, shell, homeDirectory, projid
) SELECT puuid, 'userr', snuuid, '/bin/bash', '/share/home/userr',
	 projid
    FROM ( sites JOIN projects USING(snuuid) ), principals
    WHERE siteName='toys' and name='Random User' and projName='toyusers';


INSERT INTO user_accounts (
	puuid, userName, snuuid, shell, homeDirectory, projid
) SELECT puuid, 'smarty', snuuid, '/bin/bash', '/share/home/smarty',
	 projid
    FROM ( sites JOIN projects USING(snuuid) ), principals
    WHERE siteName='toys' and name='Smart Guy' and projName='toyusers';


INSERT INTO user_accounts (
	puuid, userName, snuuid, shell, homeDirectory, groupName, projid
) SELECT puuid, 'userr', snuuid, '/bin/bash', '/share/home/userr',
	 'users', projid
    FROM ( sites JOIN projects USING(snuuid) ), principals
    WHERE siteName='test' and name='Random User' and projName='guineapigs';


INSERT INTO user_accounts (
	puuid, userName, snuuid, shell, homeDirectory, groupName, projid
) SELECT puuid, 'smarty', snuuid, '/bin/bash', '/share/home/smarty',
	 'users', projid
    FROM ( sites JOIN projects USING(snuuid) ), principals
    WHERE siteName='test' and name='Smart Guy' and projName='guineapigs';


INSERT INTO user_accounts (
	puuid, userName, snuuid, shell, homeDirectory, groupName, projid
) SELECT puuid, 'smithj', snuuid, '/bin/bash', '/share/home/smarty',
	 'users', projid
    FROM ( sites JOIN projects USING(snuuid) ), principals
    WHERE siteName='test' and name='Joe Smith' and projName='guineapigs';

-- Now some group members.

INSERT INTO group_members (snuuid,groupName,userName)
     SELECT snuuid,'admins','smarty'
     FROM sites
     WHERE siteName='toys';

INSERT INTO group_members (snuuid,groupName,userName)
     SELECT snuuid,'admins','userr'
     FROM sites
     WHERE siteName='toys';

INSERT INTO group_members (snuuid,groupName,userName)
     SELECT snuuid,'secret','smithj'
     FROM sites
     WHERE siteName='test';

-- Associate a couple 'test' accounts with 'secret' vsite.

INSERT INTO virtual_site_members (snuuid, vsid, userName)
    SELECT snuuid, vsid, 'smarty'
    FROM sites JOIN virtual_sites USING (snuuid)
    WHERE siteName='test' and vsName='secret';

INSERT INTO virtual_site_members (snuuid, vsid, userName)
    SELECT snuuid, vsid, 'smithj'
    FROM sites JOIN virtual_sites USING (snuuid)
    WHERE siteName='test' and vsName='secret';


-- Associate a 'test' group with 'secret' vsite.


INSERT INTO virtual_site_group_members (snuuid, vsid, groupName)
    SELECT snuuid, vsid, 'secret'
    FROM sites JOIN virtual_sites USING (snuuid)
    WHERE siteName='test' AND vsName='secret';

