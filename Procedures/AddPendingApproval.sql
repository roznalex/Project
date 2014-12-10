CREATE OR REPLACE PROCEDURE p_add_pending_approval(ip_feature IN T_FEATURE) IS
	v_state   T_STATE;
BEGIN	 
	/* **********************************************
	 THE PLACE FOR CHECKS WHICH THROW EXCEPTIONS
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
END p_add_pending_approval;