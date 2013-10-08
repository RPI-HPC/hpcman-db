-- Types of passwords.

CREATE TABLE password_types (
    passwordType TEXT PRIMARY KEY,
    typeDescription TEXT
);

INSERT INTO password_types
    VALUES ('crypt', 'Unix crypt');
INSERT INTO password_types
    VALUES ('md5', 'MD5 hash');
INSERT INTO password_types
    VALUES ('ssha', 'Seeded SHA hash');

--  Clear text passwords are no longer a default option
--        ('cleartext', 'Clear text password'),

