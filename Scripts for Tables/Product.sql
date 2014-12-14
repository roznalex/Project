CREATE TABLE  Product (
product_id				number(5),
group_id 				number(5),
product_uid 			number(5),
product_name			varchar(150),
product_long_name		varchar(250),
description				varchar(4000),
valid_start_date 		timestamp(6) with local time zone,
status_id 				number,
last_action_id 			number,
publish					number(1),
last_record				number(1),
linked                  number(1),
was_published           number(1),
comments                varchar2(4000),
active_flag             number(1),
last_modified_by        varchar2(200),
last_modified_date      timestamp(6) with local time zone,
created_by              varchar2(200),
created_date            timestamp(6)  with local time zone
);

ALTER TABLE Product 
	ADD CONSTRAINT pk_product    			 primary key       ( product_id );

ALTER TABLE Product 
	ADD CONSTRAINT ch_product_active_flag    check 	( active_flag in (0,1) );
	
ALTER TABLE Product 
	ADD CONSTRAINT ch_product_publish    	 check  ( publish in (0,1)  );

ALTER TABLE Product 
	ADD CONSTRAINT ch_product_last_record    check  ( last_record in (0,1) );

ALTER TABLE Product 
	ADD CONSTRAINT ch_product_linked    	 check  ( linked in (0,1) );

ALTER TABLE Product 
	ADD CONSTRAINT ch_product_was_published  check ( was_published  in (0,1) );

ALTER TABLE Product 
	ADD CONSTRAINT fk_product_status_id    	 foreign key      ( status_id )
	REFERENCES   Status  (status_id);
	
ALTER TABLE Product 
	ADD CONSTRAINT fk_product_last_action_id foreign key      ( last_action_id )
	REFERENCES   Last_action    (last_action_id);

