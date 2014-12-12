CREATE OR REPLACE PROCEDURE p_reactivate(ip_feature IN T_FEATURE) IS
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
	
	IF v_feature.status_id = /* DEACTIVATED_ID */ THEN
		v_state = T_STATE(0,1,1,/* PENDING_APPROVAL_ID */,/* REACTIVATE */);
	END IF;
	
	INSERT INTO FEATURE
	VALUES(seq_feat_feature_id.NEXTVAL,
		   FEATURE.group_id,
		   FEATURE.feature_type_id, 
		   FEATURE.feature_value, 
		   FEATURE.description, 
		   FEATURE.valid_start_date,
		   v_state.status_id,
		   v_state.last_action_id,
		   v_state.publish,
		   v_state.last_record,
		   FEATURE.linked,
		   v_state.was_published,
		   FEATURE.comments,
		   FEATURE.active_flag,
		   USER,
		   CURRENT_DATE,
		   FEATURE.created_by,
		   FEATURE.created_date,
		   FEATURE.is_default,
		   FEATURE.is_editable);
	
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
END p_reactivate;