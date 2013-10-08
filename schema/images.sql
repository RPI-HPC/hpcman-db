-- Store BLObs of Images (use for principals, approval form scans, etc)
CREATE TABLE images (
    iuuid serial,
    image_name character varying(64),
    image_type character varying(12),
    image_blob bytea,
    PRIMARY KEY (iuuid),
    CONSTRAINT image_image_type CHECK (
     (
      (
       (
	(
	 (image_type)::text = 'jpg'::text) 
	 OR (
	 (image_type)::text = 'image/jpeg'::text)
	) OR (
	 (image_type)::text = 'image/pjpeg'::text)
	) OR (
	 (image_type)::text = 'image/gif'::text)
     )
    )
);
