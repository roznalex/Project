CREATE OR REPLACE PROCEDURE p_approve(ip_feature IN T_FEATURE) IS
	v_feature              T_FEATURE;
	v_state                T_STATE;
	v_id_of_last_published NUMBER;
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
	
	IF    v_feature.status_id = /* PENDING_APPROVAL_ID */ THEN
		v_state = T_STATE(1,1,1,/* APPROVED_ID */,/* APPROVE */);
	ELSIF v_feature.status_id = /* PENDING_DEACTIVATION_ID */ THEN
		v_state = T_STATE(1,1,1,/* DEACTIVATED_ID */,/* APPROVE */);
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
		   FEATURE.is_editable)
	 WHERE FEATURE.feature_id = ip_feature.feature_id;
	
	UPDATE FEATURE
	   SET FEATURE.last_record = 0
	 WHERE FEATURE.feature_id = ip_feature.feature_id;
	 
	IF ip_feature.was_published = 1 THEN
		SELECT FEATURE.feature_id INTO v_id_of_last_published
		  FROM FEATURE
		 WHERE FEATURE.group_id  = ip_feature.group_id
		   AND FEATURE.publish = 1
		   AND FEATURE.status_id = v_state.status_id;
		
		UPDATE FEATURE
		   SET FEATURE.publish = 0
		 WHERE FEATURE.feature_id = v_id_of_last_published;
	END IF;
	 
EXCEPTION
	/* **********************************************
	 THE PLACE FOR EXCEPTIONS
	 ********************************************** */
	WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR(/* ERROR CODE */,/* ERROR TEXT */);
	/* **********************************************
	 ////////////////////////////////////////////////
	 ********************************************** */
END p_approve;