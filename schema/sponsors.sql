-- Store relations between principals that are sponsors and their 
--  sponsees
CREATE TABLE sponsors (
  snuuid bigint,  -- site
  puuid bigint,   -- sponsor
  spuuid bigint,  -- sponsee
  created timestamp with time zone default now(),
  expires timestamp with time zone,
  state char,
  -- Assume multiple sponsorship of same person by same person in same site
  --  but with different outcomes (denied once, approved second time, etc)
  PRIMARY KEY (snuuid, puuid, spuuid, state),
  FOREIGN KEY (snuuid) REFERENCES sites(snuuid),
  FOREIGN KEY (puuid) REFERENCES principals(puuid),
  FOREIGN KEY (spuuid) REFERENCES principals(puuid)
);
