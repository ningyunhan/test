INSERT INTO USERS (USER_ID, FIRST_NAME, LAST_NAME, YEAR_OF_BIRTH, MONTH_OF_BIRTH, DAY_OF_BIRTH, GENDER)
SELECT DISTINCT USER_ID, FIRST_NAME, LAST_NAME, YEAR_OF_BIRTH, MONTH_OF_BIRTH, DAY_OF_BIRTH, GENDER FROM weile.PUBLIC_USER_INFORMATION;



CREATE OR REPLACE TRIGGER friends_check
BEFORE INSERT ON FRIENDS
FOR EACH ROW
  WHEN (NEW.USER1_ID > NEW.USER2_ID)
DECLARE replace NUMBER;
BEGIN
  replace := :NEW.USER1_ID;
  :NEW.USER1_ID := :NEW.USER2_ID;
  :NEW.USER2_ID := replace;
END;
/

INSERT INTO FRIENDS (USER1_ID, USER2_ID)
SELECT DISTINCT U.USER1_ID, U.USER2_ID FROM 
 (SELECT USER1_ID, 
         USER2_ID
  FROM weile.PUBLIC_ARE_FRIENDS
  UNION ALL
  SELECT USER2_ID,
         USER1_ID
  FROM weile.PUBLIC_ARE_FRIENDS) U
WHERE U.USER2_ID > U.USER1_ID;


INSERT INTO CITIES (CITY_NAME, STATE_NAME, COUNTRY_NAME)
SELECT DISTINCT C.HOMETOWN_CITY, C.HOMETOWN_STATE, C.HOMETOWN_COUNTRY FROM
 (SELECT HOMETOWN_CITY,
         HOMETOWN_STATE,
         HOMETOWN_COUNTRY
  FROM weile.PUBLIC_USER_INFORMATION
  WHERE HOMETOWN_CITY IS NOT NULL AND HOMETOWN_STATE IS NOT NULL AND HOMETOWN_COUNTRY IS NOT NULL
 UNION
  SELECT EVENT_CITY,
         EVENT_STATE,
         EVENT_COUNTRY
  FROM weile.PUBLIC_EVENT_INFORMATION
  WHERE EVENT_CITY IS NOT NULL AND EVENT_STATE IS NOT NULL AND EVENT_COUNTRY IS NOT NULL
 UNION
  SELECT CURRENT_CITY,
         CURRENT_STATE,
         CURRENT_COUNTRY
  FROM weile.PUBLIC_USER_INFORMATION
  WHERE CURRENT_CITY IS NOT NULL AND CURRENT_STATE IS NOT NULL AND CURRENT_COUNTRY IS NOT NULL) C;



 INSERT INTO USER_CURRENT_CITY (USER_ID,CURRENT_CITY_ID)
 SELECT DISTINCT w.USER_ID, c.CITY_ID
 FROM weile.PUBLIC_USER_INFORMATION w
 INNER JOIN CITIES c
 ON w.CURRENT_CITY = c.CITY_NAME;

 INSERT INTO USER_HOMETOWN_CITY (USER_ID,HOMETOWN_CITY_ID)
 SELECT DISTINCT w.USER_ID, c.CITY_ID
 FROM weile.PUBLIC_USER_INFORMATION w
 INNER JOIN CITIES c
 ON w.HOMETOWN_CITY = c.CITY_NAME;



INSERT INTO PROGRAMS (INSTITUTION, CONCENTRATION, DEGREE)
SELECT DISTINCT INSTITUTION_NAME, PROGRAM_CONCENTRATION, PROGRAM_DEGREE FROM weile.PUBLIC_USER_INFORMATION
WHERE INSTITUTION_NAME IS NOT NULL AND PROGRAM_CONCENTRATION IS NOT NULL AND PROGRAM_DEGREE IS NOT NULL;

INSERT INTO EDUCATION (USER_ID, PROGRAM_ID, PROGRAM_YEAR)
SELECT DISTINCT w.USER_ID, P.PROGRAM_ID, w.PROGRAM_YEAR
FROM weile.PUBLIC_USER_INFORMATION w
INNER JOIN PROGRAMS P
ON w.INSTITUTION_NAME = P.INSTITUTION AND w.PROGRAM_DEGREE = P.DEGREE AND w.PROGRAM_CONCENTRATION = P.CONCENTRATION;

INSERT INTO USER_EVENTS (EVENT_ID, EVENT_CREATOR_ID, EVENT_NAME, EVENT_TAGLINE, EVENT_DESCRIPTION, EVENT_HOST, EVENT_TYPE, EVENT_SUBTYPE, EVENT_LOCATION, EVENT_CITY_ID, EVENT_START_TIME, EVENT_END_TIME)
SELECT DISTINCT E.EVENT_ID, E.EVENT_CREATOR_ID, E.EVENT_NAME, E.EVENT_TAGLINE, E.EVENT_DESCRIPTION, E.EVENT_HOST, E.EVENT_TYPE, E.EVENT_SUBTYPE, E.EVENT_LOCATION, C.CITY_ID, E.EVENT_START_TIME, E.EVENT_END_TIME
FROM weile.PUBLIC_EVENT_INFORMATION E
INNER JOIN CITIES C
ON E.EVENT_CITY = C.CITY_NAME AND E.EVENT_STATE = C.STATE_NAME AND E.EVENT_COUNTRY = C.COUNTRY_NAME;

ALTER TABLE PHOTOS DROP CONSTRAINT P_A;

INSERT INTO PHOTOS (PHOTO_ID, ALBUM_ID, PHOTO_CAPTION, PHOTO_CREATED_TIME, PHOTO_MODIFIED_TIME, PHOTO_LINK)
SELECT DISTINCT PHOTO_ID, ALBUM_ID, PHOTO_CAPTION, PHOTO_CREATED_TIME, PHOTO_MODIFIED_TIME, PHOTO_LINK
FROM weile.PUBLIC_PHOTO_INFORMATION;

INSERT INTO ALBUMS (ALBUM_ID, ALBUM_OWNER_ID, ALBUM_NAME, ALBUM_CREATED_TIME, ALBUM_MODIFIED_TIME, ALBUM_LINK, ALBUM_VISIBILITY, COVER_PHOTO_ID)
SELECT DISTINCT ALBUM_ID, OWNER_ID, ALBUM_NAME, ALBUM_CREATED_TIME, ALBUM_MODIFIED_TIME, ALBUM_LINK, ALBUM_VISIBILITY, COVER_PHOTO_ID
FROM weile.PUBLIC_PHOTO_INFORMATION;


ALTER TABLE PHOTOS
  ADD CONSTRAINT P_A 
  FOREIGN KEY (ALBUM_ID)
REFERENCES ALBUMS(ALBUM_ID);

INSERT INTO TAGS (TAG_PHOTO_ID, TAG_SUBJECT_ID, TAG_CREATED_TIME, TAG_X, TAG_Y)
SELECT DISTINCT PHOTO_ID, TAG_SUBJECT_ID, TAG_CREATED_TIME, TAG_X_COORDINATE, TAG_Y_COORDINATE
FROM weile.PUBLIC_TAG_INFORMATION;