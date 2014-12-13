/* pkg_product  */
CREATE PACKAGE pkg_product AS
	 PROCEDURE p_add_pending_approval(ip_product IN T_PRODUCT);
	 PROCEDURE p_amend(ip_product IN T_PRODUCT);
	 PROCEDURE p_approve(ip_product IN T_PRODUCT);
	 PROCEDURE p_reject(ip_product IN T_PRODUCT);
	 PROCEDURE p_discard(ip_product IN T_PRODUCT);
	 PROCEDURE p_deactivate(ip_product IN T_PRODUCT);
	 PROCEDURE p_reactivate(ip_product IN T_PRODUCT);
END pkg_product;

CREATE PACKAGE BODY pkg_product AS
	CREATE SEQUENCE seq_prod_product_id
		INCREMENT BY 1
		START WITH 1
		CACHE 20;

CREATE PACKAGE BODY pkg_product AS		
	CREATE SEQUENCE seq_prod_group_id
		INCREMENT BY 1
		START WITH 1
		CACHE 20;
  
/* p_add_pending_approval */
PROCEDURE p_add_pending_approval(ip_product IN T_PRODUCT) IS
	v_state   T_STATE;
BEGIN	 
	/* **********************************************
	 THE PLACE FOR CHECKS WHICH THROW EXCEPTIONS
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
		   CURRENT_DATE)
	 WHERE PRODUCT.product_id = ip_product.product_id;
	 
EXCEPTION
	/* **********************************************
	 THE PLACE FOR EXCEPTIONS
	 ********************************************** */
END p_add_pending_approval;

/* p_amend */
PROCEDURE p_amend(ip_product IN T_PRODUCT) IS
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
	
	IF    v_product.status_id = /* APPROVED_ID */ THEN
		v_state = T_STATE(0,1,1,/* PENDING_APPROVAL_ID */,/* AMEND */);
	ELSIF v_product.status_id = /* PENDING_APPROVAL_ID */ THEN
		v_state = T_STATE(0,1,0,/* PENDING_APPROVAL_ID */,/* AMEND */);
	ELSIF v_product.status_id = /* REJECTED_ID */ THEN
		v_state = T_STATE(0,1,0,/* PENDING_APPROVAL_ID */,/* AMEND */);
	ELSIF v_product.status_id = /* DISCARDED_ID */ THEN
		v_state = T_STATE(0,1,0,/* PENDING_APPROVAL_ID */,/* AMEND */);
	END IF;
	
	INSERT INTO PRODUCT
	VALUES(seq_prod_product_id.NEXTVAL,
		   PRODUCT.group_id,
		   PRODUCT.product_uid, 
		   COALESCE(ip_product.product_name,		PRODUCT.product_name), 
		   COALESCE(ip_product.product_long_name,	PRODUCT.product_long_name), 
		   COALESCE(ip_product.description,			PRODUCT.description), 
		   COALESCE(ip_product.valid_start_date,	PRODUCT.valid_start_date),
		   v_state.status_id,
		   v_state.last_action_id,
		   v_state.publish,
		   v_state.last_record,
		   PRODUCT.linked,
		   v_state.was_published,
		   COALESCE(ip_product.comments,        	PRODUCT.comments),
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
END p_amend;

/* p_approve */
PROCEDURE p_approve(ip_product IN T_PRODUCT) IS
	v_product T_PRODUCT;
	v_state   T_STATE;
	v_id_of_last_published NUMBER;
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
		   PRODUCT.created_date)
	 WHERE PRODUCT.product_id = product.product_id;
	
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
END p_approve;

/* p_reject */
PROCEDURE p_reject(ip_product IN T_PRODUCT) IS
	v_product                    T_PRODUCT;
	v_state                      T_STATE;
	RETURN_TO_THE_LAST_PUBLISHED BOOLEAN DEFAULT FALSE;
	v_id_of_last_published       NUMBER;
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
	
	IF    v_product.status_id = /* PENDING_APPROVAL_ID */ AND v_product.was_published = 0 THEN
		v_state = T_STATE(0,1,0,/* REJECTED_ID */,/* REJECT */);
	ELSIF v_product.status_id = /* PENDING_APPROVAL_ID */ AND v_product.was_published = 1 THEN
		v_state = T_STATE(1,1,1,/* APPROVED_ID */,/* REJECT */);
		RETURN_TO_THE_LAST_PUBLISHED := TRUE;
	ELSIF v_product.status_id = /* APPROVED_ID */ THEN
		v_state = T_STATE(0,1,1,/* PENDING_APPROVAL_ID */,/* REJECT */);
	END IF;
	
	IF RETURN_TO_THE_LAST_PUBLISHED THEN
		SELECT PRODUCT.product_id INTO v_id_of_last_published
		  FROM PRODUCT
		 WHERE PRODUCT.group_id  = ip_product.group_id
		   AND PRODUCT.publish = 1
		   AND PRODUCT.status_id = v_state.status_id;
		
		UPDATE PRODUCT
		   SET PRODUCT.last_record = v_state.last_record
		       PRODUCT.last_action_id = v_state.last_action_id
		 WHERE PRODUCT.product_id = v_id_of_last_published;
	ELSE
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
	END IF;
	
	UPDATE PRODUCT
	   SET PRODUCT.last_record = 0
	 WHERE PRODUCT.product_id = ip_product.product_id;
	 
EXCEPTION
	/* **********************************************
	 THE PLACE FOR EXCEPTIONS
	 ********************************************** */
END p_reject;

/* p_discard */
PROCEDURE p_discard(ip_product IN T_PRODUCT) IS
	v_product					 T_PRODUCT;
	v_state   					 T_STATE;
	RETURN_TO_THE_LAST_PUBLISHED BOOLEAN DEFAULT FALSE;
	v_id_of_last_published       NUMBER;
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
	
	IF    v_product.status_id = /* PENDING_APPROVAL_ID */ AND v_product.was_published = 0 THEN
		v_state = T_STATE(0,1,0,/* DISCARDED_ID */,/* DISCARD */);
	ELSIF v_product.status_id = /* PENDING_APPROVAL_ID */ AND v_product.was_published = 1 THEN
		v_state = T_STATE(1,1,1,/* APPROVED_ID */,/* DISCARD */);
		RETURN_TO_THE_LAST_PUBLISHED := TRUE;
	ELSIF v_product.status_id = /* PENDING_APPROVAL_ID */ AND v_product.was_published = 1 THEN
		v_state = T_STATE(1,1,1,/* DEACTIVATED_ID */,/* DISCARD */);
		RETURN_TO_THE_LAST_PUBLISHED := TRUE;
	ELSIF v_product.status_id = /* APPROVED_ID */ THEN
		v_state = T_STATE(0,1,1,/* PENDING_APPROVAL_ID */,/* DISCARD */);
	END IF;
	
	IF RETURN_TO_THE_LAST_PUBLISHED THEN
		SELECT PRODUCT.product_id INTO v_id_of_last_published
		  FROM PRODUCT
		 WHERE PRODUCT.group_id  = ip_product.group_id
		   AND PRODUCT.publish = 1
		   AND PRODUCT.status_id = v_state.status_id;
		
		UPDATE PRODUCT
		   SET PRODUCT.last_record = v_state.last_record
		       PRODUCT.last_action_id = v_state.last_action_id
		 WHERE PRODUCT.product_id = v_id_of_last_published;
	ELSE
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
		 WHERE PRODUCT.product_id = ip_product.product_id;
	END IF;
	
	UPDATE PRODUCT
	   SET PRODUCT.last_record = 0
	 WHERE PRODUCT.product_id = ip_product.product_id;
	 
EXCEPTION
	/* **********************************************
	 THE PLACE FOR EXCEPTIONS
	 ********************************************** */
END p_discard;

/* p_deactivate */
PROCEDURE p_deactivate(ip_product IN T_PRODUCT) IS
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
		   PRODUCT.created_date)
	 WHERE PRODUCT.product_id = product.product_id;
	
	UPDATE PRODUCT
	   SET PRODUCT.last_record = 0
	 WHERE PRODUCT.product_id = ip_product.product_id;
	 
EXCEPTION
	/* **********************************************
	 THE PLACE FOR EXCEPTIONS
	 ********************************************** */
END p_deactivate;

/* p_reactivate */
PROCEDURE p_reactivate(ip_product IN T_PRODUCT) IS
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