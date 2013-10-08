-- Functions to determine the latest of several times.

CREATE OR REPLACE FUNCTION
max_time(a TIMESTAMP WITH TIME ZONE,
         b TIMESTAMP WITH TIME ZONE)
RETURNS TIMESTAMP WITH TIME ZONE AS $body$
BEGIN
    IF a > b THEN
        RETURN a;
    ELSE
        RETURN b;
    END IF;
END;
$body$ LANGUAGE plpgsql IMMUTABLE;


CREATE OR REPLACE FUNCTION
time_latest(a TIMESTAMP WITH TIME ZONE,
             b TIMESTAMP WITH TIME ZONE,
             c TIMESTAMP WITH TIME ZONE)
RETURNS TIMESTAMP WITH TIME ZONE AS $body$
BEGIN
    IF a >= b AND a >= c THEN
        RETURN a;
    ELSIF b >= a AND b >= c THEN
        RETURN b;
    ELSE
        RETURN c;
    END IF;
END;
$body$ LANGUAGE plpgsql IMMUTABLE;


CREATE OR REPLACE FUNCTION
time_latest4(a TIMESTAMP WITH TIME ZONE,
             b TIMESTAMP WITH TIME ZONE,
             c TIMESTAMP WITH TIME ZONE,
             d TIMESTAMP WITH TIME ZONE)
RETURNS TIMESTAMP WITH TIME ZONE AS $body$
BEGIN
    IF a >= b AND a >= c AND a >= d THEN
        RETURN a;
    ELSIF b >= a AND b >= c AND b >= d THEN
        RETURN b;
    ELSIF c >= a AND c >= b AND c >= d THEN
        RETURN c;
    ELSE
        RETURN d;
    END IF;
END;
$body$ LANGUAGE plpgsql IMMUTABLE;


CREATE OR REPLACE FUNCTION
time_latest5(a TIMESTAMP WITH TIME ZONE,
             b TIMESTAMP WITH TIME ZONE,
             c TIMESTAMP WITH TIME ZONE,
             d TIMESTAMP WITH TIME ZONE,
             e TIMESTAMP WITH TIME ZONE)
RETURNS TIMESTAMP WITH TIME ZONE AS $body$
BEGIN
    IF a >= b AND a >= c AND a >= d AND a >= e THEN
        RETURN a;
    ELSIF b >= a AND b >= c AND b >= d AND b >= e THEN
        RETURN b;
    ELSIF c >= a AND c >= b AND c >= d AND c >= e THEN
        RETURN c;
    ELSIF d >= a AND d >= b AND d >= c AND d >= e THEN
        RETURN d;
    ELSE
        RETURN e;
    END IF;
END;
$body$ LANGUAGE plpgsql IMMUTABLE;
