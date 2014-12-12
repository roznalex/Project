CREATE OR REPLACE PROCEDURE p_approve(ip_product IN T_PRODUCT) IS
	v_product T_PRODUCT;
	v_state   T_STATE;
	v_id_of_last_published NUMBER;
BEGIN
	SELECT * INTO v_product
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
	
	IF    v_product.status_id = /* PENDING_APPROVAL_ID */ THEN
		v_state = T_STATE(1,1,1,/* APPROVED_ID */,/* APPROVE */);
	ELSIF v_product.status_id = /* PENDING_DEACTIVATION_ID */ THEN
		v_state = T_STATE(1,1,1,/* DEACTIVATED_ID */,/* APPROVE */);
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
	 
	IF ip_product.was_published = 1 THEN
		SELECT PRODUCT.product_id INTO v_id_of_last_published
		  FROM PRODUCT
		 WHERE PRODUCT.group_id  = ip_product.group_id
		   AND PRODUCT.publish = 1
		   AND PRODUCT.status_id = /* APPROVED_ID */;
		
		UPDATE PRODUCT
	       SET PRODUCT.last_record = 0
	     WHERE PRODUCT.product_id = v_id_of_last_published;
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