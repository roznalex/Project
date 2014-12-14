CREATE OR REPLACE TYPE T_STATE AS OBJECT
	(publish        NUMBER(1),
	 last_record    NUMBER(1),
	 was_published  NUMBER(1),
	 status_id      NUMBER,
	 last_action_id NUMBER);
	 
CREATE OR REPLACE TYPE T_FEATURE AS OBJECT 
	(feature_id			NUMBER,
	 group_id 			NUMBER,
	 feature_type_id	NUMBER, 
	 feature_value		VARCHAR2(200), 
	 description 		VARCHAR2(4000), 
	 valid_start_date   TIMESTAMP(6) WITH LOCAL TIME ZONE,
	 status_id 			NUMBER,
	 last_action_id		NUMBER,
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
	 
CREATE SEQUENCE seq_feat_feature_id
		INCREMENT BY 1
		START WITH 1
		CACHE 20;
		
CREATE SEQUENCE seq_feat_group_id
		INCREMENT BY 1
		START WITH 1
		CACHE 20;