CREATE OR REPLACE TYPE T_STATE AS OBJECT
	(publish       NUMBER(0,1),
	 last_record   NUMBER(0,1),
	 was_published NUMBER(0,1),
	 status_id     NUMBER,
	 last_action   NUMBER);
	 
CREATE OR REPLACE TYPE T_PRODUCT AS OBJECT 
	(product_id			NUMBER,
	 group_id 			NUMBER,
	 product_uid		NUMBER, 
	 product_name		VARCHAR2(150), 
	 product_long_name	VARCHAR2(250), 
	 description		VARCHAR2(4000),
	 valid_start_date   TIMESTAMP(6) WITH LOCAL TIMEZONE,
	 status_id 			NUMBER,
	 last_action_id		NUMBER,
	 publish 			NUMBER(0,1),
	 last_record        NUMBER(0,1),
	 linked             NUMBER(0,1),
	 was_published      NUMBER(0,1),
	 comments           VARCHAR2(4000),
	 active_flag        NUMBER(0,1),
	 last_modified_by   VARCHAR2(200),
	 last_modified_date TIMESTAMP(6) WITH LOCAL TIMEZONE,
	 created_by         VARCHAR2(200),
	 created_date       TIMESTAMP(6) WITH LOCAL TIMEZONE
	 lnk_feature		TBL_LNK_FEATURE);

CREATE OR REPLACE TYPE T_LNK_FEATURE AS OBJECT
	(feature_id			NUMBER,
	 feature_type_id    NUMBER);
	 
CREATE OR REPLACE TYPE TBL_LNK_FEATURE AS TABLE OF T_LNK_FEATURE;

CREATE SEQUENCE seq_lnk_prod_feat_id
		INCREMENT BY 1
		START WITH 1
		CACHE 20;