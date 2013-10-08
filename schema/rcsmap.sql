-- Map RCS data to principals
CREATE TABLE rcsmap (
  puuid bigint,
  rcsid varchar(10) NOT NULL,
  rcsrin integer,
  link boolean DEFAULT FALSE NOT NULL,
  PRIMARY KEY (puuid),
  UNIQUE (rcsrin),
  FOREIGN KEY (puuid) REFERENCES principals(puuid)
);
