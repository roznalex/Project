CREATE OR REPLACE PROCEDURE p_reactivate(ip_product IN T_PRODUCT) IS
	v_product T_PRODUCT;
	v_state   T_STATE;
BEGIN
	SELECT * INTO v_product
	  FROM PRODUCT
	 WHERE PRODUCT.product_id = ip_product.product_id;
	 
	/* **********************************************
	 THE PLACE FOR CHECKS WHICH THROW EXCEPTIONS
	 ********************************************** */
	
	IF v_product.status_id = /* DEACTIVATED_ID */ THEN
		v_state = T_STATE(0,1,1,/* PENDING_APPROVAL_ID */,/* REACTIVATE */);
	END IF;
	
	INSERT INTO PRODUCT
	VALUES(seq_prod_product_id.NEXTVAL,
		   PRODUCT.group_id,
		   PRODUCT.product_uid, 
		   PRODUCT.product_name, 
		   PRODUCT.product_long_name
		   PRODUCT.description, 
		   PRODUCT.valid_start_date,
		   v_state.status_id,
		   v_state.last_action_id,
		   v_state.publish,
		   v_state.last_record,
		   PRODUCT.linked,
		   v_state.was_published,
		   PRODUCT.comments,
		   PRODUCT.active_flag,
		   USER,
		   CURRENT_DATE,
		   PRODUCT.created_by,
		   PRODUCT.created_date)
	 WHERE PRODUCT.product_id = product.product_id;
	
	UPDATE PRODUCT
	   SET PRODUCT.last_record = 0
	 WHERE PRODUCT.product_id = ip_product.product_id;
	 
EXCEPTION
	/* **********************************************
	 THE PLACE FOR EXCEPTIONS
	 ********************************************** */
END p_reactivate;