create or replace TYPE T_FEATURE AS OBJECT 
	(feature_id			NUMBER(5),
	 group_id 			NUMBER(5),
	 feature_type_id	NUMBER(5), 
	 feature_value		VARCHAR2(200), 
	 description 		VARCHAR2(4000), 
	 valid_start_date   TIMESTAMP(6) WITH LOCAL TIME ZONE,
	 status_id 			NUMBER(5),
	 last_action_id		NUMBER(5),
	 publish 			   NUMBER(1),
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
	 
create or replace TYPE T_PRODUCT AS OBJECT 
(product_id			      	NUMBER(5),
	 group_id 			    NUMBER(5),
	 product_uid		    NUMBER(5), 
	 product_name		    VARCHAR2(150), 
	 product_long_name		VARCHAR2(250), 
	 description		    VARCHAR2(4000),
	 valid_start_date   	TIMESTAMP(6) WITH LOCAL TIME ZONE,
	 status_id 			    NUMBER(5),
	 last_action_id		  	NUMBER(5),
	 publish 			    NUMBER(1),
	 last_record        	NUMBER(1),
	 was_published      	NUMBER(1),
	 comments           	VARCHAR2(4000),
	 active_flag        	NUMBER(1),
	 last_modified_by   	VARCHAR2(200),
	 last_modified_date 	TIMESTAMP(6) WITH LOCAL TIME ZONE,
	 created_by         	VARCHAR2(200),
	 created_date       	TIMESTAMP(6) WITH LOCAL TIME ZONE,
	 lnk_feature		    TBL_LNK_FEATURE);
	 
create or replace TYPE T_LNK_FEATURE AS OBJECT
	(feature_id			NUMBER(5),
	 feature_type_id    NUMBER(5),
	 feature_value      VARCHAR2(200));
	 
create or replace TYPE TBL_LNK_FEATURE AS TABLE OF T_LNK_FEATURE;

create or replace TYPE T_STATE AS OBJECT
	(publish          NUMBER(1),
	 last_record      NUMBER(1),
	 was_published 	  NUMBER(1),
	 status_id        NUMBER(5),
	 last_action_id   NUMBER(5));
	 
CREATE SEQUENCE SEQ_LNK_PROD_FEAT_ID
	MINVALUE 1
	INCREMENT BY 1
	START WITH 1;

CREATE SEQUENCE SEQ_PROD_PRODUCT_ID
	MINVALUE 1
	INCREMENT BY 1 
	START WITH 1;
	
CREATE SEQUENCE SEQ_PROD_GROUP_ID
	MINVALUE 1
	INCREMENT BY 1 
	START WITH 1;
	
CREATE SEQUENCE SEQ_FEAT_FEATURE_ID
	MINVALUE 1
	INCREMENT BY 1 
	START WITH 1;
		
CREATE SEQUENCE SEQ_FEAT_GROUP_ID
	MINVALUE 1
	INCREMENT BY 1 
	START WITH 1;