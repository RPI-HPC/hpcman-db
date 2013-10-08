create sequence fwruuid_seq;

create table firewall_exception_states (state char(1) PRIMARY KEY, description text);

INSERT INTO firewall_exception_states (state, description) VALUES ('E','Enabled');
INSERT INTO firewall_exception_states (state, description) VALUES ('D','Disabled');
INSERT INTO firewall_exception_states (state, description) VALUES ('R','Removed');

CREATE TABLE firewall_exceptions (
	fwruuid bigint PRIMARY KEY default nextval('fwruuid_seq'),
	snuuid bigint NOT NULL,
	projid bigint NOT NULL,
	requestor bigint NOT NULL,
	remoteip inet NOT NULL,
	remoteport int,
	localip inet NOT NULL,
	localport int,
	rule_state char(1) not null default 'E',
	grp text,
	notes text,
	foreign key (requestor) references principals (puuid),
	foreign key (snuuid,projid) references projects (snuuid, projid),
	foreign key (rule_state) references firewall_exception_states (state)
);


