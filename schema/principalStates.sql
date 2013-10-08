-- Store state codes and descritpions of principals
CREATE TABLE principalStates (
  principalState char,
  principalStateName varchar(30),
  principalStateDesc text,
  PRIMARY KEY(principalState)
);
-- Populate table
INSERT INTO principalStates
    VALUES
        ('C', 'Created, not approved.',
         'Principal''s data has been entered into the system but has not yet been approved.');
INSERT INTO principalStates
    VALUES
        ('A', 'Approved.',
         'Principal has been approved for assignment to projects.');
INSERT INTO principalStates
    VALUES
        ('U', 'Not approved.',
	 'Principal has not been approved for assignment to projects. May act as PI.');
