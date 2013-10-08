-- Store state codes and descritpions of projects
CREATE TABLE project_states (
  projectstate char,
  projectstatedesc text,
  PRIMARY KEY(projectstate)
);
-- Populate table
INSERT INTO project_states
    VALUES ('E','Enabled');
INSERT INTO project_states
    VALUES ('D', 'Disabled');
