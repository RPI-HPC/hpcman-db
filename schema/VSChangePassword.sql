-- Provide a function to allow a password to be changed.

CREATE OR REPLACE FUNCTION
vs_change_password(theSnuuid BIGINT, theVsid BIGINT,
                   thePuuid BIGINT, theAuthid BIGINT,
                   thePasswordType TEXT, thePassword TEXT)
RETURNS INT AS $body$
DECLARE
    vsa vs_user_information%ROWTYPE;
BEGIN
    -- Verify that the caller actually is privileged to change the password.
    -- The database role calling this function should be able to change
    -- passwords within one or more virtual sites.  Look for user accounts
    -- within those virtual sites that belong to puuid.  If one of them uses
    -- the authenticator authid, then passwords for that authenticator may be
    -- changed.

    SELECT *
        INTO vsa
        FROM vs_user_information
        WHERE snuuid=theSnuuid AND vsid=theVsid
            AND puuid=thePuuid AND authid=theAuthid;
    IF NOT found THEN
        RAISE EXCEPTION
            'no occurrences of puuid %, authid % in snnuid %, vsid %',
                thePuuid, theAuthid, theSnuuid, theVsid;
    END IF;

    -- Return 1 if we merely update, 2 if we created a new password entry.
    UPDATE passwords
        SET password=thePassword
        WHERE puuid=thePuuid AND authid=theAuthid
            AND passwordType=thePasswordType;
    IF found THEN
        RETURN 1;
    END IF;
    INSERT
        INTO passwords(puuid,authid,passwordType,password)
        VALUES (thePuuid, theAuthid, thePasswordType, thePasswordType);
    RETURN 2;
END;
$body$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION
    vs_change_password(BIGINT, BIGINT, BIGINT, BIGINT, TEXT, TEXT)
    TO vspasswdadmin;
