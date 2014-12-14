CREATE TABLE   Feature_type (
	feature_type_id          number(5),
	feature_type_name        varchar2(200),
	description              varchar2(1500)
	active_flag              number(1),
	last_modified_by         varchar2(200),
	last_modified_date       timestamp(6) with local time zone,
	created_by               varchar2(200),
	created_date             timestamp(6)  with local timez one
);

ALTER TABLE Feature_type
	ADD CONSTRAINT pk_feature_type primary key ( feature_type_id );
	
ALTER TABLE Feature_type
	ADD CONSTRAINT ch_feature_type_act_flag check ( active_flag in (0,1));
	

