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
	 created_date       TIMESTAMP(6) WITH LOCAL TIMEZONE);
	 
CREATE OR REPLACE TYPE T_LNK_FEATURE AS TABLE OF NUMBER;