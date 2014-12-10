CREATE OR REPLACE PROCEDURE p_amend(ip_feature IN T_FEATURE) IS
	v_feature T_FEATURE;
	v_state   T_STATE;
BEGIN
	SELECT * INTO v_feature
	  FROM FEATURE
	 WHERE FEATURE.feature_id = ip_feature.feature_id;
	 
	/* **********************************************
	 THE PLACE FOR CHECKS WHICH THROW EXCEPTIONS
	 ********************************************** */
	CASE
		WHEN SQL%NOTFOUND THEN RAISE NO_DATA_FOUND
	END;
	/* **********************************************
	 ////////////////////////////////////////////////
	 ********************************************** */
	
	IF    v_feature.status_id = /* APPROVED_ID */ THEN
		v_state = T_STATE(0,1,1,/* PENDING_APPROVAL_ID */,/* AMEND */);
	ELSIF v_feature.status_id = /* PENDING_APPROVAL_ID */ THEN
		v_state = T_STATE(0,1,0,/* PENDING_APPROVAL_ID */,/* AMEND */);
	ELSIF v_feature.status_id = /* REJECTED_ID */ THEN
		v_state = T_STATE(0,1,0,/* PENDING_APPROVAL_ID */,/* AMEND */);
	ELSIF v_feature.status_id = /* DISCARDED_ID */ THEN
		v_state = T_STATE(0,1,0,/* PENDING_APPROVAL_ID */,/* AMEND */);
	END IF;
	
	INSERT INTO FEATURE
	VALUES(seq_feat_feature_id.NEXTVAL,
		   FEATURE.group_id,
		   FEATURE.feature_type_id, 
		   COALESCE(ip_feature.feature_value,    FEATURE.feature_value), 
		   COALESCE(ip_feature.description,      FEATURE.description), 
		   COALESCE(ip_feature.valid_start_date, FEATURE.valid_start_date),
		   v_state.status_id,
		   v_state.last_action_id,
		   v_state.publish,
		   v_state.last_record,
		   FEATURE.linked,
		   v_state.was_published,
		   COALESCE(ip_feature.comments,         FEATURE.comments),
		   FEATURE.active_flag,
		   USER,
		   CURRENT_DATE,
		   FEATURE.created_by,
		   FEATURE.created_date,
		   FEATURE.is_default,
		   FEATURE.is_editable)
	 WHERE FEATURE.feature_id = ip_feature.feature_id;
	
	UPDATE FEATURE
	   SET FEATURE.last_record = 0
	 WHERE FEATURE.feature_id = ip_feature.feature_id;
	 
EXCEPTION
	/* **********************************************
	 THE PLACE FOR EXCEPTIONS
	 ********************************************** */
	WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR(/* ERROR CODE */,/* ERROR TEXT */);
	/* **********************************************
	 ////////////////////////////////////////////////
	 ********************************************** */
END p_amend;