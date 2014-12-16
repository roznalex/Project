CREATE TABLE   Last_action (
	last_action_id           number(5),
	last_action_name         varchar2(300),
	active_flag              number(1),
	last_modified_by         varchar2(200),
	last_modified_date       timestamp(6) with local time zone,
	created_by               varchar2(200),
	created_date             timestamp(6)  with local time zone
);

ALTER TABLE Last_action
	ADD CONSTRAINT pk_last_action primary key (last_action_id);

ALTER TABLE Last_action
	ADD CONSTRAINT ch_last_action_act_flag check (active_flag in (0,1));
