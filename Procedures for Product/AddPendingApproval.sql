CREATE OR REPLACE PROCEDURE p_add_pending_approval(ip_product IN T_PRODUCT) IS
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

	INSERT INTO PRODUCT
	VALUES(seq_prod_product_id.NEXTVAL,
		   seq_prod_group_id.NEXTVAL,
		   PRODUCT.product_uid,
		   ip_product.product_name, 
		   ip_product.product_long_name,
		   ip_product.description,
		   ip_product.valid_start_date,
		   v_state.status_id,
		   v_state.last_action_id,
		   v_state.publish,
		   v_state.last_record,
		   ip_product.linked,
		   v_state.was_published,
		   ip_product.comments,
		   ip_product.active_flag,
		   USER,
		   CURRENT_DATE,
		   USER,
		   CURRENT_DATE);
	 
	FOR i IN ip_product.lnk_feature.FIRST..ip_product.lnk_feature.LAST
	LOOP
		INSERT INTO LNK_PRODUCT_FEATURE
		VALUES(seq_lnk_prod_feat_id.NEXTVAL,
			   ip_product.product_id,
			   ip_product.lnk_feature(i).feature_id,
			   ip_product.active_flag,
			   USER,
			   CURRENT_DATE,
			   USER,
			   CURRENT_DATE);
		
		UPDATE FEATURE
		   SET FEATURE.linked = 1
		 WHERE FEATURE.feature_id =  ip_product.lnk_feature(i).feature_id,
		   AND FEATURE.linked = 0;
	END LOOP;
	
	
	
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