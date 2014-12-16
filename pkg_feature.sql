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

create or replace PACKAGE BODY PKG_FEATURE AS

  PROCEDURE p_add_pending_approval(ip_feature IN T_FEATURE) AS
    v_state   T_STATE;
  BEGIN	 
    /* **********************************************
     THE PLACE FOR CHECKS WHICH THROW EXCEPTIONS
     ********************************************** */
    IF FALSE THEN
      RAISE NO_DATA_FOUND;
    END IF;
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */
     
    v_state := T_STATE(0,1,0,1/* PENDING_APPROVAL_ID */,1/* ADD_PENDING_APPROVAL */);
  
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
         0,
         v_state.was_published,
         ip_feature.comments,
         ip_feature.active_flag,
         USER,
         CURRENT_DATE,
         USER,
         CURRENT_DATE,
         ip_feature.is_default,
         ip_feature.is_editable);
     
  EXCEPTION
    /* **********************************************
     THE PLACE FOR EXCEPTIONS
     ********************************************** */
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(1/* ERROR CODE */,1/* ERROR TEXT */);
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */
  END p_add_pending_approval;

  PROCEDURE p_amend(ip_feature IN T_FEATURE) AS
  v_feature T_FEATURE;
	v_state   T_STATE;
  BEGIN
    SELECT T_FEATURE(FEATURE.feature_id,
                     FEATURE.group_id,
                     FEATURE.feature_type_id,
                     FEATURE.feature_value,
                     FEATURE.description,
                     FEATURE.valid_start_date,
                     FEATURE.status_id,
                     FEATURE.last_action_id,
                     FEATURE.publish,
                     FEATURE.last_record,
                     FEATURE.linked,
                     FEATURE.was_published,
                     FEATURE.comments,
                     FEATURE.active_flag,
                     FEATURE.last_modified_by,
                     FEATURE.last_modified_date,
                     FEATURE.created_by,
                     FEATURE.created_date,
                     FEATURE.is_default,
                     FEATURE.is_editable) INTO v_feature
      FROM FEATURE
     WHERE FEATURE.feature_id = ip_feature.feature_id;
     
    /* **********************************************
     THE PLACE FOR CHECKS WHICH THROW EXCEPTIONS
     ********************************************** */
    IF SQL%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */
    
    IF    v_feature.status_id = 4/* APPROVED_ID */ THEN
      v_state := T_STATE(0,1,1,1/* PENDING_APPROVAL_ID */,2/* AMEND */);
    ELSIF v_feature.status_id = 1/* PENDING_APPROVAL_ID */ THEN
      v_state := T_STATE(0,1,v_feature.was_published,1/* PENDING_APPROVAL_ID */,2/* AMEND */);
    ELSIF v_feature.status_id = 3/* REJECTED_ID */ THEN
      v_state := T_STATE(0,1,0,1/* PENDING_APPROVAL_ID */,2/* AMEND */);
    ELSIF v_feature.status_id = 2/* DISCARDED_ID */ THEN
      v_state := T_STATE(0,1,0,1/* PENDING_APPROVAL_ID */,2/* AMEND */);
    END IF;
    
    INSERT INTO FEATURE
    VALUES(seq_feat_feature_id.NEXTVAL,
           v_feature.group_id,
           v_feature.feature_type_id, 
           COALESCE(ip_feature.feature_value,    v_feature.feature_value), 
           COALESCE(ip_feature.description,      v_feature.description), 
           COALESCE(ip_feature.valid_start_date, v_feature.valid_start_date),
           v_state.status_id,
           v_state.last_action_id,
           v_state.publish,
           v_state.last_record,
           v_feature.linked,
           v_state.was_published,
           COALESCE(ip_feature.comments,         v_feature.comments),
           v_feature.active_flag,
           USER,
           CURRENT_DATE,
           v_feature.created_by,
           v_feature.created_date,
           v_feature.is_default,
           v_feature.is_editable);
    
    UPDATE FEATURE
       SET FEATURE.last_record = 0
     WHERE FEATURE.feature_id = v_feature.feature_id;
	 
  EXCEPTION
	/* **********************************************
	 THE PLACE FOR EXCEPTIONS
	 ********************************************** */
	WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR(1/* ERROR CODE */,'NO_DATA_FOUND'/* ERROR TEXT */);
	/* **********************************************
	 ////////////////////////////////////////////////
	 ********************************************** */
  END p_amend;

  PROCEDURE p_approve(ip_feature IN T_FEATURE) AS
    v_feature              T_FEATURE;
    v_state                T_STATE;
    v_id_of_last_published NUMBER(5);
    v_id_of_last_pub_status NUMBER(5);
  BEGIN
    SELECT T_FEATURE(FEATURE.feature_id,
                     FEATURE.group_id,
                     FEATURE.feature_type_id,
                     FEATURE.feature_value,
                     FEATURE.description,
                     FEATURE.valid_start_date,
                     FEATURE.status_id,
                     FEATURE.last_action_id,
                     FEATURE.publish,
                     FEATURE.last_record,
                     FEATURE.linked,
                     FEATURE.was_published,
                     FEATURE.comments,
                     FEATURE.active_flag,
                     FEATURE.last_modified_by,
                     FEATURE.last_modified_date,
                     FEATURE.created_by,
                     FEATURE.created_date,
                     FEATURE.is_default,
                     FEATURE.is_editable) INTO v_feature
      FROM FEATURE
     WHERE FEATURE.feature_id = ip_feature.feature_id;
     
    /* **********************************************
     THE PLACE FOR CHECKS WHICH THROW EXCEPTIONS
     ********************************************** */
    IF SQL%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */
    
    IF    v_feature.status_id = 1/* PENDING_APPROVAL_ID */ THEN
      v_state := T_STATE(1,1,1,4/* APPROVED_ID */,5/* APPROVE */);
    ELSIF v_feature.status_id = 5/* PENDING_DEACTIVATION_ID */ THEN
      v_state := T_STATE(1,1,1,6/* DEACTIVATED_ID */,5/* APPROVE */);
    END IF;
    
    IF v_feature.was_published = 1 THEN
      SELECT FEATURE.status_id INTO v_id_of_last_pub_status
        FROM FEATURE
       WHERE FEATURE.group_id  = v_feature.group_id
         AND FEATURE.publish = 1;
      
      SELECT FEATURE.feature_id INTO v_id_of_last_published
        FROM FEATURE
       WHERE FEATURE.group_id  = v_feature.group_id
         AND FEATURE.publish = 1
         AND FEATURE.status_id = v_id_of_last_pub_status;
      
      UPDATE FEATURE
         SET FEATURE.publish = 0
       WHERE FEATURE.feature_id = v_id_of_last_published;
    END IF;
    
    INSERT INTO FEATURE
    VALUES(seq_feat_feature_id.NEXTVAL,
           v_feature.group_id,
           v_feature.feature_type_id, 
           v_feature.feature_value, 
           v_feature.description, 
           v_feature.valid_start_date,
           v_state.status_id,
           v_state.last_action_id,
           v_state.publish,
           v_state.last_record,
           v_feature.linked,
           v_state.was_published,
           v_feature.comments,
           v_feature.active_flag,
           USER,
           CURRENT_DATE,
           v_feature.created_by,
           v_feature.created_date,
           v_feature.is_default,
           v_feature.is_editable);
    
    UPDATE FEATURE
       SET FEATURE.last_record = 0
     WHERE FEATURE.feature_id = v_feature.feature_id;
     
  EXCEPTION
	/* **********************************************
	 THE PLACE FOR EXCEPTIONS
	 ********************************************** */
	WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR(-20001/* ERROR CODE */,'NO_DATA_FOUND'/* ERROR TEXT */);
	/* **********************************************
	 ////////////////////////////////////////////////
	 ********************************************** */
  END p_approve;

  PROCEDURE p_reject(ip_feature IN T_FEATURE) AS
    v_feature                    T_FEATURE;
    v_state                      T_STATE;
    RETURN_TO_THE_LAST_PUBLISHED BOOLEAN DEFAULT FALSE;
    v_id_of_last_published       NUMBER(5);
  BEGIN
    SELECT T_FEATURE(FEATURE.feature_id,
                     FEATURE.group_id,
                     FEATURE.feature_type_id,
                     FEATURE.feature_value,
                     FEATURE.description,
                     FEATURE.valid_start_date,
                     FEATURE.status_id,
                     FEATURE.last_action_id,
                     FEATURE.publish,
                     FEATURE.last_record,
                     FEATURE.linked,
                     FEATURE.was_published,
                     FEATURE.comments,
                     FEATURE.active_flag,
                     FEATURE.last_modified_by,
                     FEATURE.last_modified_date,
                     FEATURE.created_by,
                     FEATURE.created_date,
                     FEATURE.is_default,
                     FEATURE.is_editable) INTO v_feature
      FROM FEATURE
     WHERE FEATURE.feature_id = ip_feature.feature_id;
     
    /* **********************************************
     THE PLACE FOR CHECKS WHICH THROW EXCEPTIONS
     ********************************************** */
    IF SQL%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */
    
    IF    v_feature.status_id = 1/* PENDING_APPROVAL_ID */ AND v_feature.was_published = 0 THEN
      v_state := T_STATE(0,1,0,3/* REJECTED_ID */,4/* REJECT */);
    ELSIF v_feature.status_id = 1/* PENDING_APPROVAL_ID */ AND v_feature.was_published = 1 THEN
      v_state := T_STATE(1,1,1,4/* APPROVED_ID */,4/* REJECT */);
      RETURN_TO_THE_LAST_PUBLISHED := TRUE;
    END IF;
    
    IF RETURN_TO_THE_LAST_PUBLISHED THEN     
      SELECT FEATURE.feature_id INTO v_id_of_last_published
        FROM FEATURE
       WHERE FEATURE.group_id  = v_feature.group_id
         AND FEATURE.publish = 1
         AND FEATURE.status_id = v_state.status_id;
      
      UPDATE FEATURE
         SET FEATURE.last_record = v_state.last_record,
             FEATURE.last_action_id = v_state.last_action_id,
             FEATURE.last_modified_by = USER,
             FEATURE.last_modified_date = CURRENT_DATE
       WHERE FEATURE.feature_id = v_id_of_last_published;
    ELSE
      INSERT INTO FEATURE
      VALUES(seq_feat_feature_id.NEXTVAL,
             v_feature.group_id,
             v_feature.feature_type_id, 
             v_feature.feature_value, 
             v_feature.description, 
             v_feature.valid_start_date,
             v_state.status_id,
             v_state.last_action_id,
             v_state.publish,
             v_state.last_record,
             v_feature.linked,
             v_state.was_published,
             v_feature.comments,
             v_feature.active_flag,
             USER,
             CURRENT_DATE,
             v_feature.created_by,
             v_feature.created_date,
             v_feature.is_default,
             v_feature.is_editable);
    END IF;
    
    UPDATE FEATURE
       SET FEATURE.last_record = 0
     WHERE FEATURE.feature_id = v_feature.feature_id;
     
  EXCEPTION
    /* **********************************************
     THE PLACE FOR EXCEPTIONS
     ********************************************** */
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20001/* ERROR CODE */,'NO_DATA_FOUND'/* ERROR TEXT */);
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */
  END p_reject;

  PROCEDURE p_discard(ip_feature IN T_FEATURE) AS
  v_feature                    T_FEATURE;
	v_state                      T_STATE;
	RETURN_TO_THE_LAST_PUBLISHED BOOLEAN DEFAULT FALSE;
	v_id_of_last_published       NUMBER(5);
  BEGIN
    SELECT T_FEATURE(FEATURE.feature_id,
                     FEATURE.group_id,
                     FEATURE.feature_type_id,
                     FEATURE.feature_value,
                     FEATURE.description,
                     FEATURE.valid_start_date,
                     FEATURE.status_id,
                     FEATURE.last_action_id,
                     FEATURE.publish,
                     FEATURE.last_record,
                     FEATURE.linked,
                     FEATURE.was_published,
                     FEATURE.comments,
                     FEATURE.active_flag,
                     FEATURE.last_modified_by,
                     FEATURE.last_modified_date,
                     FEATURE.created_by,
                     FEATURE.created_date,
                     FEATURE.is_default,
                     FEATURE.is_editable) INTO v_feature
      FROM FEATURE
     WHERE FEATURE.feature_id = ip_feature.feature_id;
     
    /* **********************************************
     THE PLACE FOR CHECKS WHICH THROW EXCEPTIONS
     ********************************************** */
    IF SQL%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */
    
    IF    v_feature.status_id = 1/* PENDING_APPROVAL_ID */ AND v_feature.was_published = 0 THEN
      v_state := T_STATE(0,1,0,2/* DISCARDED_ID */,3/* DISCARD */);
    ELSIF v_feature.status_id = 1/* PENDING_APPROVAL_ID */ AND v_feature.was_published = 1 THEN
      v_state := T_STATE(1,1,1,6/* DEACTIVATED_ID */,3/* DISCARD */);
      RETURN_TO_THE_LAST_PUBLISHED := TRUE;
    END IF;
    
    IF RETURN_TO_THE_LAST_PUBLISHED THEN
      SELECT FEATURE.feature_id INTO v_id_of_last_published
        FROM FEATURE
       WHERE FEATURE.group_id  = v_feature.group_id
         AND FEATURE.publish = 1
         AND FEATURE.status_id = v_state.status_id;
      
      UPDATE FEATURE
         SET FEATURE.last_record = v_state.last_record,
             FEATURE.last_action_id = v_state.last_action_id,
             FEATURE.last_modified_by = USER,
             FEATURE.last_modified_date = CURRENT_DATE
       WHERE FEATURE.feature_id = v_id_of_last_published;
    ELSE
      INSERT INTO FEATURE
      VALUES(seq_feat_feature_id.NEXTVAL,
             v_feature.group_id,
             v_feature.feature_type_id, 
             v_feature.feature_value, 
             v_feature.description, 
             v_feature.valid_start_date,
             v_state.status_id,
             v_state.last_action_id,
             v_state.publish,
             v_state.last_record,
             v_feature.linked,
             v_state.was_published,
             v_feature.comments,
             v_feature.active_flag,
             USER,
             CURRENT_DATE,
             v_feature.created_by,
             v_feature.created_date,
             v_feature.is_default,
             v_feature.is_editable);
    END IF;
    
    UPDATE FEATURE
       SET FEATURE.last_record = 0
     WHERE FEATURE.feature_id = v_feature.feature_id;
     
  EXCEPTION
    /* **********************************************
     THE PLACE FOR EXCEPTIONS
     ********************************************** */
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20001/* ERROR CODE */,'NO_DATA_FOUND'/* ERROR TEXT */);
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */
  END p_discard;

  PROCEDURE p_deactivate(ip_feature IN T_FEATURE) AS
  v_feature T_FEATURE;
	v_state   T_STATE;
  BEGIN
    SELECT T_FEATURE(FEATURE.feature_id,
                     FEATURE.group_id,
                     FEATURE.feature_type_id,
                     FEATURE.feature_value,
                     FEATURE.description,
                     FEATURE.valid_start_date,
                     FEATURE.status_id,
                     FEATURE.last_action_id,
                     FEATURE.publish,
                     FEATURE.last_record,
                     FEATURE.linked,
                     FEATURE.was_published,
                     FEATURE.comments,
                     FEATURE.active_flag,
                     FEATURE.last_modified_by,
                     FEATURE.last_modified_date,
                     FEATURE.created_by,
                     FEATURE.created_date,
                     FEATURE.is_default,
                     FEATURE.is_editable) INTO v_feature
      FROM FEATURE
     WHERE FEATURE.feature_id = ip_feature.feature_id;
     
    /* **********************************************
     THE PLACE FOR CHECKS WHICH THROW EXCEPTIONS
     ********************************************** */
    IF SQL%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */
    
    IF v_feature.status_id = 4/* APPROVED */ THEN
      v_state := T_STATE(0,1,1,5/* PENDING_DEACTIVATION_ID */,6/* DEACTIVATE */);
    END IF;
    
    INSERT INTO FEATURE
      VALUES(seq_feat_feature_id.NEXTVAL,
             v_feature.group_id,
             v_feature.feature_type_id, 
             v_feature.feature_value, 
             v_feature.description, 
             v_feature.valid_start_date,
             v_state.status_id,
             v_state.last_action_id,
             v_state.publish,
             v_state.last_record,
             v_feature.linked,
             v_state.was_published,
             v_feature.comments,
             v_feature.active_flag,
             USER,
             CURRENT_DATE,
             v_feature.created_by,
             v_feature.created_date,
             v_feature.is_default,
             v_feature.is_editable);
    
    UPDATE FEATURE
       SET FEATURE.last_record = 0
     WHERE FEATURE.feature_id = v_feature.feature_id;
     
  EXCEPTION
    /* **********************************************
     THE PLACE FOR EXCEPTIONS
     ********************************************** */
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20001/* ERROR CODE */,'NO_DATA_FOUND'/* ERROR TEXT */);
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */
  END p_deactivate;

  PROCEDURE p_reactivate(ip_feature IN T_FEATURE) AS
    v_feature T_FEATURE;
    v_state   T_STATE;
  BEGIN
    SELECT T_FEATURE(FEATURE.feature_id,
                     FEATURE.group_id,
                     FEATURE.feature_type_id,
                     FEATURE.feature_value,
                     FEATURE.description,
                     FEATURE.valid_start_date,
                     FEATURE.status_id,
                     FEATURE.last_action_id,
                     FEATURE.publish,
                     FEATURE.last_record,
                     FEATURE.linked,
                     FEATURE.was_published,
                     FEATURE.comments,
                     FEATURE.active_flag,
                     FEATURE.last_modified_by,
                     FEATURE.last_modified_date,
                     FEATURE.created_by,
                     FEATURE.created_date,
                     FEATURE.is_default,
                     FEATURE.is_editable) INTO v_feature
      FROM FEATURE
     WHERE FEATURE.feature_id = ip_feature.feature_id;
     
    /* **********************************************
     THE PLACE FOR CHECKS WHICH THROW EXCEPTIONS
     ********************************************** */
    IF SQL%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */
    
    IF v_feature.status_id = 6/* DEACTIVATED_ID */ THEN
      v_state := T_STATE(0,1,1,1/* PENDING_APPROVAL_ID */,7/* REACTIVATE */);
    END IF;
    
    INSERT INTO FEATURE
      VALUES(seq_feat_feature_id.NEXTVAL,
             v_feature.group_id,
             v_feature.feature_type_id, 
             v_feature.feature_value, 
             v_feature.description, 
             v_feature.valid_start_date,
             v_state.status_id,
             v_state.last_action_id,
             v_state.publish,
             v_state.last_record,
             v_feature.linked,
             v_state.was_published,
             v_feature.comments,
             v_feature.active_flag,
             USER,
             CURRENT_DATE,
             v_feature.created_by,
             v_feature.created_date,
             v_feature.is_default,
             v_feature.is_editable);
    
    UPDATE FEATURE
       SET FEATURE.last_record = 0
     WHERE FEATURE.feature_id = v_feature.feature_id;
     
  EXCEPTION
    /* **********************************************
     THE PLACE FOR EXCEPTIONS
     ********************************************** */
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(1/* ERROR CODE */,'NO_DATA_FOUND'/* ERROR TEXT */);
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */
  END p_reactivate;

END PKG_FEATURE;