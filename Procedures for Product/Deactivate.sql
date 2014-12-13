CREATE OR REPLACE PROCEDURE p_deactivate(ip_product IN T_PRODUCT) IS
	v_product T_PRODUCT;
	v_state   T_STATE;
BEGIN
	SELECT T_PRODUCT(product_id,
					 group_id,
					 product_uid,
					 product_name,
					 product_long_name,
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
					 NULL) INTO v_product
	  FROM PRODUCT
	 WHERE PRODUCT.product_id = ip_product.product_id;
	 
	/* **********************************************
	 THE PLACE FOR CHECKS WHICH THROW EXCEPTIONS
	 ********************************************** */
	CASE
		WHEN SQL%NOTFOUND THEN RAISE NO_DATA_FOUND
	END;
	/* **********************************************
	 ////////////////////////////////////////////////
	 ********************************************** */
	
	IF v_product.status_id = /* PENDING_DEACTIVATION_ID */ THEN
		v_state = T_STATE(1,1,1,/* DEACTIVATED_ID */,/* DEACTIVATE */);
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
		   PRODUCT.created_date);
	
	UPDATE PRODUCT
	   SET PRODUCT.last_record = 0
	 WHERE PRODUCT.product_id = ip_product.product_id;
	 
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