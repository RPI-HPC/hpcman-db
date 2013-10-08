-- Store relations between VOs, member people, and sites
CREATE TABLE VOAssoc (
  puuid bigint REFERENCES principals
    ON DELETE CASCADE,
  snuuid bigint REFERENCES sites
    ON DELETE CASCADE,
  vpuuid bigint REFERENCES principals(puuid)
    ON DELETE CASCADE,
  creation timestamp with time zone DEFAULT NOW(),
  PRIMARY KEY (puuid, snuuid, vpuuid)
);
