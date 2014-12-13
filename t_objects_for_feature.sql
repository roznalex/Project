CREATE OR REPLACE TYPE T_STATE AS OBJECT
	(publish       NUMBER(1),
	 last_record   NUMBER(1),
	 was_published NUMBER(1),
	 status_id     NUMBER(10),
	 last_action   NUMBER(10));
/	 
CREATE OR REPLACE TYPE T_FEATURE AS OBJECT 
	(feature_id			NUMBER(5),
	 group_id 			NUMBER(5),
	 feature_type_id	NUMBER(5), 
	 feature_value		VARCHAR2(200), 
	 description 		VARCHAR2(4000), 
	 valid_start_date   TIMESTAMP(6) WITH LOCAL TIME ZONE,
	 status_id 			NUMBER(4),
	 last_action_id		NUMBER(9),
	 publish 			NUMBER(1),
	 last_record        NUMBER(1),
	 linked             NUMBER(1),
	 was_published      NUMBER(1),
	 comments           VARCHAR2(4000),
	 active_flag        NUMBER(1),
	 last_modified_by   VARCHAR2(200),
	 last_modified_date TIMESTAMP(6) WITH LOCAL TIME ZONE,
	 created_by         VARCHAR2(200),
	 created_date       TIMESTAMP(6) WITH LOCAL TIME ZONE,
	 is_default         NUMBER(1),
	 is_editable        NUMBER(1));
   /