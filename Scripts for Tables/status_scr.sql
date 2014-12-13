CREATE TABLE   Status (
	status_id               number,
	status_name             varchar2(100),
	active_flag             number(0,1),
	last_modified_by        varchar2(200),
	last_modified_date      timestamp(6) with local timezone,
	created_by              varchar2(200),
	created_date            timestamp(6)  with local timezone
);

ALTER TABLE Status
	ADD CONSTRAINT pk_status primary key ( status_id );
	
ALTER TABLE Status
	ADD CONSTRAINT ch_status_act_flag check (active_flag in (0,1));

