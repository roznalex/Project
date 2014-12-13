/* pkg_feature  */
CREATE PACKAGE pkg_feature AS
	 PROCEDURE p_add_pending_approval(ip_feature IN T_FEATURE);
	 PROCEDURE p_amend(ip_feature IN T_FEATURE);
	 PROCEDURE p_approve(ip_feature IN T_FEATURE);
	 PROCEDURE p_reject(ip_feature IN T_FEATURE);
	 PROCEDURE p_discard(ip_feature IN T_FEATURE);
	 PROCEDURE p_deactivate(ip_feature IN T_FEATURE);
	 PROCEDURE p_reactivate(ip_feature IN T_FEATURE);
END pkg_feature;

CREATE PACKAGE BODY pkg_feature AS
	CREATE SEQUENCE seq_feat_feature_id
		INCREMENT BY 1
		START WITH 1
		CACHE 20;

CREATE PACKAGE BODY pkg_feature AS		
	CREATE SEQUENCE seq_feat_group_id
		INCREMENT BY 1
		START WITH 1
		CACHE 20;
  
/* p_add_pending_approval */
PROCEDURE p_add_pending_approval(ip_feature IN T_FEATURE) IS
	v_state   T_STATE;
BEGIN	 
	/* **********************************************
	 THE PLACE FOR CHECKS WHICH THROW EXCEPTIONS
	 ********************************************** */
	CASE
		WHEN /* FAILED CHECK */ THEN RAISE /* EXCEPTION */
	END;
	/* **********************************************
	 ////////////////////////////////////////////////
	 ********************************************** */
	 
	v_state = T_STATE(0,1,0,/* PENDING_APPROVAL_ID */,/* ADD_PENDING_APPROVAL */);

	INSERT INTO FEATURE
	VALUES(seq_feat_feature_id.NEXTVAL,
		   seq_feat_group_id.NEXTVAL,
		   ip_feature.feature_type_id, 
		   ip_feature.feature_value, 
		   ip_feature.description, 
		   ip_feature.valid_start_date,
		   v_state.status_id,
		   v_state.last_action_id,
		   v_state.publish,
		   v_state.last_record,
		   ip_feature.linked,
		   v_state.was_published,
		   ip_feature.comments,
		   ip_feature.active_flag,
		   USER,
		   CURRENT_DATE,
		   USER,
		   CURRENT_DATE,
		   ip_feature.is_default,
		   ip_feature.is_editable)
	 
EXCEPTION
	/* **********************************************
	 THE PLACE FOR EXCEPTIONS
	 ********************************************** */
	WHEN /* EXCEPTION */ THEN
		RAISE_APPLICATION_ERROR(/* ERROR CODE */,/* ERROR TEXT */);
	/* **********************************************
	 ////////////////////////////////////////////////
	 ********************************************** */
END p_add_pending_approval;

/* p_amend */
PROCEDURE p_amend(ip_feature IN T_FEATURE) IS
	v_feature T_FEATURE;
	v_state   T_STATE;
BEGIN
	SELECT T_FEATURE(feature_id,
					 group_id,
					 feature_type_id,
					 feature_value,
					 description,
					 valid_start_date,
					 status_id,
					 last_action_id,
					 publish,
					 last_record,
					 linked,
					 was_published,
					 comments,
					 active_flag,
					 last_modified_by,
					 last_modified_date,
					 created_by,
					 created_date,
					 is_default,
					 is_editable) INTO v_feature
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

/* p_approve */
PROCEDURE p_approve(ip_feature IN T_FEATURE) IS
	v_feature              T_FEATURE;
	v_state                T_STATE;
	v_id_of_last_published NUMBER;
BEGIN
	SELECT T_FEATURE(feature_id,
					 group_id,
					 feature_type_id,
					 feature_value,
					 description,
					 valid_start_date,
					 status_id,
					 last_action_id,
					 publish,
					 last_record,
					 linked,
					 was_published,
					 comments,
					 active_flag,
					 last_modified_by,
					 last_modified_date,
					 created_by,
					 created_date,
					 is_default,
					 is_editable) INTO v_feature
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

/* p_reject */
PROCEDURE p_reject(ip_feature IN T_FEATURE) IS
	v_feature                    T_FEATURE;
	v_state                      T_STATE;
	RETURN_TO_THE_LAST_PUBLISHED BOOLEAN DEFAULT FALSE;
	v_id_of_last_published       NUMBER;
BEGIN
	SELECT T_FEATURE(feature_id,
					 group_id,
					 feature_type_id,
					 feature_value,
					 description,
					 valid_start_date,
					 status_id,
					 last_action_id,
					 publish,
					 last_record,
					 linked,
					 was_published,
					 comments,
					 active_flag,
					 last_modified_by,
					 last_modified_date,
					 created_by,
					 created_date,
					 is_default,
					 is_editable) INTO v_feature
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
	
	IF    v_feature.status_id = /* PENDING_APPROVAL_ID */ AND v_feature.was_published = 0 THEN
		v_state = T_STATE(0,1,0,/* REJECTED_ID */,/* REJECT */);
	ELSIF v_feature.status_id = /* PENDING_APPROVAL_ID */ AND v_feature.was_published = 1 THEN
		v_state = T_STATE(1,1,1,/* APPROVED_ID */,/* REJECT */);
		RETURN_TO_THE_LAST_PUBLISHED := TRUE;
	ELSIF v_feature.status_id = /* APPROVED_ID */ THEN
		v_state = T_STATE(0,1,1,/* PENDING_APPROVAL_ID */,/* REJECT */);
	END IF;
	
	IF RETURN_TO_THE_LAST_PUBLISHED THEN
		SELECT FEATURE.feature_id INTO v_id_of_last_published
		  FROM FEATURE
		 WHERE FEATURE.group_id  = ip_feature.group_id
		   AND FEATURE.publish = 1
		   AND FEATURE.status_id = v_state.status_id;
		
		UPDATE FEATURE
		   SET FEATURE.last_record = v_state.last_record
		       FEATURE.last_action_id = v_state.last_action_id
		 WHERE FEATURE.feature_id = v_id_of_last_published;
	ELSE
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
	END IF;
	
	IF v_feature.status_id = /* APPROVED_ID */ THEN
		UPDATE FEATURE
		   SET FEATURE.last_record = 0
		   SET FEATURE.publish = 0
		 WHERE FEATURE.feature_id = ip_feature.feature_id;
	ELSE
		UPDATE FEATURE
		   SET FEATURE.last_record = 0
		 WHERE FEATURE.feature_id = ip_feature.feature_id;
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
END p_reject;

/* p_discard */
PROCEDURE p_discard(ip_feature IN T_FEATURE) IS
	v_feature                    T_FEATURE;
	v_state                      T_STATE;
	RETURN_TO_THE_LAST_PUBLISHED BOOLEAN DEFAULT FALSE;
	v_id_of_last_published       NUMBER;
BEGIN
	SELECT T_FEATURE(feature_id,
					 group_id,
					 feature_type_id,
					 feature_value,
					 description,
					 valid_start_date,
					 status_id,
					 last_action_id,
					 publish,
					 last_record,
					 linked,
					 was_published,
					 comments,
					 active_flag,
					 last_modified_by,
					 last_modified_date,
					 created_by,
					 created_date,
					 is_default,
					 is_editable) INTO v_feature
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
	
	IF    v_feature.status_id = /* PENDING_APPROVAL_ID */ AND v_feature.was_published = 0 THEN
		v_state = T_STATE(0,1,0,/* DISCARDED_ID */,/* DISCARD */);
	ELSIF v_feature.status_id = /* PENDING_APPROVAL_ID */ AND v_feature.was_published = 1 THEN
		v_state = T_STATE(1,1,1,/* APPROVED_ID */,/* DISCARD */);
		RETURN_TO_THE_LAST_PUBLISHED := TRUE;
	ELSIF v_feature.status_id = /* PENDING_APPROVAL_ID */ AND v_feature.was_published = 1 THEN
		v_state = T_STATE(1,1,1,/* DEACTIVATED_ID */,/* DISCARD */);
		RETURN_TO_THE_LAST_PUBLISHED := TRUE;
	ELSIF v_feature.status_id = /* APPROVED_ID */ THEN
		v_state = T_STATE(0,1,1,/* PENDING_APPROVAL_ID */,/* DISCARD */);
	END IF;
	
	IF RETURN_TO_THE_LAST_PUBLISHED THEN
		SELECT FEATURE.feature_id INTO v_id_of_last_published
		  FROM FEATURE
		 WHERE FEATURE.group_id  = ip_feature.group_id
		   AND FEATURE.publish = 1
		   AND FEATURE.status_id = v_state.status_id;
		
		UPDATE FEATURE
		   SET FEATURE.last_record = v_state.last_record
		       FEATURE.last_action_id = v_state.last_action_id
		 WHERE FEATURE.feature_id = v_id_of_last_published;
	ELSE
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
	END IF;
	
	IF v_feature.status_id = /* APPROVED_ID */ THEN
		UPDATE FEATURE
		   SET FEATURE.last_record = 0
		   SET FEATURE.publish = 0
		 WHERE FEATURE.feature_id = ip_feature.feature_id;
	ELSE
		UPDATE FEATURE
		   SET FEATURE.last_record = 0
		 WHERE FEATURE.feature_id = ip_feature.feature_id;
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
END p_discard;

/* p_deactivate */
PROCEDURE p_deactivate(ip_feature IN T_FEATURE) IS
	v_feature T_FEATURE;
	v_state   T_STATE;
BEGIN
	SELECT T_FEATURE(feature_id,
					 group_id,
					 feature_type_id,
					 feature_value,
					 description,
					 valid_start_date,
					 status_id,
					 last_action_id,
					 publish,
					 last_record,
					 linked,
					 was_published,
					 comments,
					 active_flag,
					 last_modified_by,
					 last_modified_date,
					 created_by,
					 created_date,
					 is_default,
					 is_editable) INTO v_feature
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
	
	IF v_feature.status_id = /* PENDING_DEACTIVATION_ID */ THEN
		v_state = T_STATE(1,1,1,/* DEACTIVATED_ID */,/* DEACTIVATE */);
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
	 
EXCEPTION
	/* **********************************************
	 THE PLACE FOR EXCEPTIONS
	 ********************************************** */
	WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR(/* ERROR CODE */,/* ERROR TEXT */);
	/* **********************************************
	 ////////////////////////////////////////////////
	 ********************************************** */
END p_deactivate;

/* p_reactivate */
PROCEDURE p_reactivate(ip_feature IN T_FEATURE) IS
	v_feature T_FEATURE;
	v_state   T_STATE;
BEGIN
	SELECT T_FEATURE(feature_id,
					 group_id,
					 feature_type_id,
					 feature_value,
					 description,
					 valid_start_date,
					 status_id,
					 last_action_id,
					 publish,
					 last_record,
					 linked,
					 was_published,
					 comments,
					 active_flag,
					 last_modified_by,
					 last_modified_date,
					 created_by,
					 created_date,
					 is_default,
					 is_editable) INTO v_feature
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
END p_reactivate;
