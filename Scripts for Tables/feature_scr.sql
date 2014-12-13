CREATE TABLE   Feature (
	feature _id                         number,
	group_id                            number,
	feature_type_id                     number,
	feature _value                      varchar2(200),
	description                         varchar(4000),
	valid_start_date                    timestamp(6) with local time zone,
	status_id                           number,
	last_action_id                      number,
	publish                             number(0,1),
	last_record                         number(0,1),
	linked                              number(0,1),
	was_published                       number(0,1),
	comments                            varchar2(4000),
	active_flag                         number(0,1),
	last_modified_by                    varchar2(200),
	last_modified_date                  timestamp(6) with local timezone,
	created_by                          varchar2(200),
	created_date                        timestamp(6)  with local timezone,
	is_default                          number(0,1),
	is_editable                         number(0,1)
);

ALTER TABLE Feature
ADD CONSTRAINT pk_feature primary key (feature _id);

ALTER TABLE Feature
ADD CONSTRAINT ch_feature_def check (is_default in (0,1);

ALTER TABLE Feature
ADD CONSTRAINT ch_feature_edit check (is_editable in (0,1));

ALTER TABLE Feature
ADD CONSTRAINT ch_feature_act_flag check (active_flag in (0,1));

ALTER TABLE Feature
ADD CONSTRAINT ch_feature_pub check ( publish in (0,1));

ALTER TABLE Feature
ADD CONSTRAINT ch_feature_rec check (last_record  in (0,1));

ALTER TABLE Feature
ADD CONSTRAINT ch_feature_lnk check (linked  in (0,1));

ALTER TABLE Feature
ADD CONSTRAINT ch_feature_wpub check (was_published in (0,1));

ALTER TABLE Feature
ADD CONSTRAINT fk_feature_ftype foreign key (feature _type_id)
REFERENCES Feature_type (feature_type_id);

ALTER TABLE Feature
ADD CONSTRAINT fk_feature_status foreign key (status_id)
REFERENCES Status (status_id);

ALTER TABLE Feature
ADD CONSTRAINT fk_feature_laction foreign key (last_action_id)
REFERENCES Last_action (last_action_id);
