-- States of groups

CREATE  TABLE group_states (
    groupState char(1) PRIMARY KEY,
    groupStateDesc text NOT NULL
);

INSERT INTO group_states
    VALUES
        ('A', 'Active');
INSERT INTO group_states
    VALUES
        ('D', 'Disabled');
INSERT INTO group_states
    VALUES
        ('R', 'Removed');
