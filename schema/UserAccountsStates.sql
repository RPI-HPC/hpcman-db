-- States of user accounts.

CREATE  TABLE user_accounts_states (
    userAccountState char(1) PRIMARY KEY,
    userAccountStateDesc text NOT NULL
);

INSERT INTO user_accounts_states
    VALUES
        ('A', 'Active');
INSERT INTO user_accounts_states
    VALUES
        ('D', 'Disabled');
INSERT INTO user_accounts_states
    VALUES
        ('R', 'Removed');
