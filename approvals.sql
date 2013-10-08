-- Store relations between approvals, principals, and sites
CREATE TABLE approvals (
  apuuid bigint, -- principal making approval
  puuid bigint,  -- principal being approved
  timestamp timestamp with time zone default now(),
  snuuid bigint,
  state boolean, -- false=pending, true=approved
  iuuid bigint REFERENCES images(iuuid),
  PRIMARY KEY (apuuid, puuid, snuuid),
  FOREIGN KEY (apuuid) REFERENCES principals(puuid),
  FOREIGN KEY (puuid) REFERENCES principals(puuid),
  FOREIGN KEY (snuuid) REFERENCES sites(snuuid)
);
