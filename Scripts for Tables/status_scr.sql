CREATE TABLE   Status (
	status_id               number(5),
	status_name             varchar2(100),
	active_flag             number(1),
	last_modified_by        varchar2(200),
	last_modified_date      timestamp(6) with local time zone,
	created_by              varchar2(200),
	created_date            timestamp(6)  with local time zone
);

ALTER TABLE Status
	ADD CONSTRAINT pk_status primary key ( status_id );
	
ALTER TABLE Status
	ADD CONSTRAINT ch_status_act_flag check (active_flag in (0,1));

