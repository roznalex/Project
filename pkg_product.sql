create or replace PACKAGE PKG_PRODUCT AS 
   PROCEDURE p_add_pending_approval(ip_product IN T_PRODUCT);
	 PROCEDURE p_amend(ip_product IN T_PRODUCT);
	 PROCEDURE p_approve(ip_product IN T_PRODUCT);
	 PROCEDURE p_reject(ip_product IN T_PRODUCT);
	 PROCEDURE p_discard(ip_product IN T_PRODUCT);
	 PROCEDURE p_deactivate(ip_product IN T_PRODUCT);
	 PROCEDURE p_reactivate(ip_product IN T_PRODUCT);
	 PROCEDURE p_curr_lnk_feat_for_prod(ip_product_id IN NUMBER(5), iop_lnk_feature_id IN OUT TBL_LNK_FEATURE);
END PKG_PRODUCT;

create or replace PACKAGE BODY PKG_PRODUCT AS

  PROCEDURE p_curr_lnk_feat_for_prod(ip_product_id IN NUMBER, iop_lnk_feature_id IN OUT TBL_LNK_FEATURE) AS
    CURSOR c_lnk_feat_for_prod(cip_product_id IN NUMBER) IS
      SELECT lnk.feature_id
        FROM LNK_PRODUCT_FEATURE lnk
       WHERE lnk.product_id = cip_product_id;
    v_count INT;
  BEGIN
    /*FOR cursor_feature_id IN c_lnk_feat_for_prod(ip_product_id)
    LOOP
      iop_lnk_feature_id(v_count).feature_id := cursor_feature_id;
      v_count := v_count + 1;
    END LOOP;*/
    OPEN c_lnk_feat_for_prod(ip_product_id);
    
    v_count := c_lnk_feat_for_prod%ROWCOUNT;
    
    FOR i IN 1..v_count
    LOOP
      FETCH c_lnk_feat_for_prod INTO iop_lnk_feature_id(i).feature_id;
    END LOOP;
    
    CLOSE c_lnk_feat_for_prod;
  END p_curr_lnk_feat_for_prod;
  
  PROCEDURE p_add_pending_approval(ip_product IN T_PRODUCT) AS
  v_state T_STATE;
  BEGIN	 
    /* **********************************************
     THE PLACE FOR CHECKS WHICH THROW EXCEPTIONS
     ********************************************** */
     IF SQL%NOTFOUND/* FAILED CHECK */ THEN 
      RAISE NO_DATA_FOUND/* EXCEPTION */;
     END IF;
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */
       
    v_state := T_STATE(0,1,0,1/* PENDING_APPROVAL_ID */,1/* ADD_PENDING_APPROVAL */);
  
    INSERT INTO PRODUCT
    VALUES(seq_prod_product_id.NEXTVAL,
           seq_prod_group_id.NEXTVAL,
           ip_product.product_uid,
           ip_product.product_name, 
           ip_product.product_long_name,
           ip_product.description,
           ip_product.valid_start_date,
           v_state.status_id,
           v_state.last_action_id,
           v_state.publish,
           v_state.last_record,
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
       WHERE FEATURE.feature_id = ip_product.lnk_feature(i).feature_id
         AND FEATURE.linked = 0;
    END LOOP;

  EXCEPTION
    /* **********************************************
     THE PLACE FOR EXCEPTIONS
     ********************************************** */
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(10001/* ERROR CODE */,'You are not able to use this system action with current status of the entity'/* ERROR TEXT */);
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */
  END p_add_pending_approval;
    
  PROCEDURE p_amend(ip_product IN T_PRODUCT) AS
  v_product T_PRODUCT;
  v_state   T_STATE;
  BEGIN
    SELECT T_PRODUCT(PRODUCT.product_id,
					 PRODUCT.group_id,
					 PRODUCT.product_uid,
					 PRODUCT.product_name,
					 PRODUCT.product_long_name,
					 PRODUCT.description,
					 PRODUCT.valid_start_date,
					 PRODUCT.status_id,
					 PRODUCT.last_action_id,
					 PRODUCT.publish,
					 PRODUCT.last_record,
					 PRODUCT.was_published,
					 PRODUCT.comments,
					 PRODUCT.active_flag,
					 PRODUCT.last_modified_by,
					 PRODUCT.last_modified_date,
					 PRODUCT.created_by,
					 PRODUCT.created_date,
					 NULL) INTO v_product
	  FROM PRODUCT
	 WHERE PRODUCT.product_id = ip_product.product_id;
    /* **********************************************
     THE PLACE FOR CHECKS WHICH THROW EXCEPTIONS
     ********************************************** */
     IF SQL%NOTFOUND/* FAILED CHECK */ THEN 
      RAISE NO_DATA_FOUND/* EXCEPTION */;
     END IF;
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */
    IF    v_product.status_id = 4/* APPROVED_ID */ THEN
          v_state := T_STATE(0,1,1,1/* PENDING_APPROVAL_ID */,4/* AMEND */);
    ELSIF v_product.status_id = 1/* PENDING_APPROVAL_ID */ THEN
          v_state := T_STATE(0,1,0,1/* PENDING_APPROVAL_ID */,4/* AMEND */);
    ELSIF v_product.status_id = 3/* REJECTED_ID */ THEN
          v_state := T_STATE(0,1,0,1/* PENDING_APPROVAL_ID */,4/* AMEND */);
    ELSIF v_product.status_id = 2/* DISCARDED_ID */ THEN
          v_state := T_STATE(0,1,0,1/* PENDING_APPROVAL_ID */,4/* AMEND */);
    END IF;
	
    INSERT INTO PRODUCT
    VALUES(seq_prod_product_id.NEXTVAL,
           v_product.group_id,
           COALESCE(ip_product.product_uid,               v_product.product_uid),
           COALESCE(ip_product.product_name,		  v_product.product_name), 
           COALESCE(ip_product.product_long_name,	v_product.product_long_name), 
           COALESCE(ip_product.description,			  v_product.description), 
           COALESCE(ip_product.valid_start_date,	v_product.valid_start_date),
           v_state.status_id,
           v_state.last_action_id,
           v_state.publish,
           v_state.last_record,
           v_state.was_published,
           COALESCE(ip_product.comments,        	v_product.comments),
           v_product.active_flag,
           USER,
           CURRENT_DATE,
           v_product.created_by,
           v_product.created_date);
	
    UPDATE PRODUCT
      SET PRODUCT.last_record = 0
    WHERE PRODUCT.product_id = ip_product.product_id;
    
    FOR i IN ip_product.lnk_feature.FIRST..ip_product.lnk_feature.LAST
    LOOP
      INSERT INTO LNK_PRODUCT_FEATURE
      VALUES(seq_lnk_prod_feat_id.NEXTVAL,
             seq_prod_product_id.CURRVAL,
             ip_product.lnk_feature(i).feature_id,
             ip_product.active_flag,
             USER,
             CURRENT_DATE,
             USER,
             CURRENT_DATE);
      
      UPDATE FEATURE
         SET FEATURE.linked = 1
       WHERE FEATURE.feature_id = ip_product.lnk_feature(i).feature_id
         AND FEATURE.linked = 0;
    END LOOP;
  
  EXCEPTION
    /* **********************************************
     THE PLACE FOR EXCEPTIONS
     ********************************************** */
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(10001/* ERROR CODE */,'You are not able to use this system action with current status of the entity'/* ERROR TEXT */);
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */   
  END p_amend;

  PROCEDURE p_approve(ip_product IN T_PRODUCT) AS
  v_product T_PRODUCT;
	v_state   T_STATE;
	v_id_of_last_published NUMBER(5);
  v_list_lnk_feature TBL_LNK_FEATURE;
  BEGIN
    SELECT T_PRODUCT(PRODUCT.product_id,
					 PRODUCT.group_id,
					 PRODUCT.product_uid,
					 PRODUCT.product_name,
					 PRODUCT.product_long_name,
					 PRODUCT.description,
					 PRODUCT.valid_start_date,
					 PRODUCT.status_id,
					 PRODUCT.last_action_id,
					 PRODUCT.publish,
					 PRODUCT.last_record,
					 PRODUCT.was_published,
					 PRODUCT.comments,
					 PRODUCT.active_flag,
					 PRODUCT.last_modified_by,
					 PRODUCT.last_modified_date,
					 PRODUCT.created_by,
					 PRODUCT.created_date,
					 NULL) INTO v_product
	  FROM PRODUCT
    WHERE PRODUCT.product_id = ip_product.product_id;
    /* **********************************************
     THE PLACE FOR CHECKS WHICH THROW EXCEPTIONS
     ********************************************** */
     IF SQL%NOTFOUND/* FAILED CHECK */ THEN 
      RAISE NO_DATA_FOUND/* EXCEPTION */;
     END IF;
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */
    IF    v_product.status_id = 1/* PENDING_APPROVAL_ID */ THEN
          v_state := T_STATE(1,1,1,4/* APPROVED_ID */,5/* APPROVE */);
    ELSIF v_product.status_id = 5/* PENDING_DEACTIVATION_ID */ THEN
          v_state := T_STATE(1,1,1,6/* DEACTIVATED_ID */,5/* APPROVE */);
    END IF;
    
    INSERT INTO PRODUCT
    VALUES(seq_prod_product_id.NEXTVAL,
           v_product.group_id,
           v_product.product_uid, 
           v_product.product_name, 
           v_product.product_long_name,
           v_product.description, 
           v_product.valid_start_date,
           v_state.status_id,
           v_state.last_action_id,
           v_state.publish,
           v_state.last_record,
           v_state.was_published,
           v_product.comments,
           v_product.active_flag,
           USER,
           CURRENT_DATE,
           v_product.created_by,
           v_product.created_date);
	
    UPDATE PRODUCT
       SET PRODUCT.last_record = 0
     WHERE PRODUCT.product_id = ip_product.product_id;
	 
    IF v_product.was_published = 1 THEN
      SELECT PRODUCT.product_id INTO v_id_of_last_published
        FROM PRODUCT
       WHERE PRODUCT.group_id  = v_product.group_id
         AND PRODUCT.publish = 1
         AND PRODUCT.status_id = 4/* APPROVED_ID */;
      
      UPDATE PRODUCT
         SET PRODUCT.last_record = 0
       WHERE PRODUCT.product_id = v_id_of_last_published;
    END IF;
    
    p_curr_lnk_feat_for_prod(v_product.product_id,v_list_lnk_feature);
    
    FOR i IN v_list_lnk_feature.FIRST..v_list_lnk_feature.LAST
    LOOP
      INSERT INTO LNK_PRODUCT_FEATURE
      VALUES(seq_lnk_prod_feat_id.NEXTVAL,
             seq_prod_product_id.CURRVAL,
             v_list_lnk_feature(i).feature_id,
             v_product.active_flag,
             USER,
             CURRENT_DATE,
             USER,
             CURRENT_DATE);
    END LOOP;
    
    EXCEPTION
    /* **********************************************
     THE PLACE FOR EXCEPTIONS
     ********************************************** */
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(10001/* ERROR CODE */,'You are not able to use this system action with current status of the entity'/* ERROR TEXT */);
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */   
  END p_approve;

  PROCEDURE p_reject(ip_product IN T_PRODUCT) AS
  v_product                    T_PRODUCT;
	v_state                      T_STATE;
	RETURN_TO_THE_LAST_PUBLISHED BOOLEAN DEFAULT FALSE;
	v_id_of_last_published       NUMBER(5);
  v_list_lnk_feature TBL_LNK_FEATURE;
  BEGIN
    SELECT T_PRODUCT(PRODUCT.product_id,
					 PRODUCT.group_id,
					 PRODUCT.product_uid,
					 PRODUCT.product_name,
					 PRODUCT.product_long_name,
					 PRODUCT.description,
					 PRODUCT.valid_start_date,
					 PRODUCT.status_id,
					 PRODUCT.last_action_id,
					 PRODUCT.publish,
					 PRODUCT.last_record,
					 PRODUCT.was_published,
					 PRODUCT.comments,
					 PRODUCT.active_flag,
					 PRODUCT.last_modified_by,
					 PRODUCT.last_modified_date,
					 PRODUCT.created_by,
					 PRODUCT.created_date,
					 NULL) INTO v_product
	  FROM PRODUCT
	 WHERE PRODUCT.product_id = ip_product.product_id;
    /* **********************************************
     THE PLACE FOR CHECKS WHICH THROW EXCEPTIONS
     ********************************************** */
     IF SQL%NOTFOUND/* FAILED CHECK */ THEN 
      RAISE NO_DATA_FOUND/* EXCEPTION */;
     END IF;
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */
    IF    v_product.status_id = 1/* PENDING_APPROVAL_ID */ AND v_product.was_published = 0 THEN
          v_state := T_STATE(0,1,0,3/* REJECTED_ID */,3/* REJECT */);
    ELSIF v_product.status_id = 1/* PENDING_APPROVAL_ID */ AND v_product.was_published = 1 THEN
          v_state := T_STATE(1,1,1,4/* APPROVED_ID */,3/* REJECT */);
          RETURN_TO_THE_LAST_PUBLISHED := TRUE;
    END IF;
    
    IF RETURN_TO_THE_LAST_PUBLISHED THEN
        SELECT PRODUCT.product_id INTO v_id_of_last_published
          FROM PRODUCT
         WHERE PRODUCT.group_id  = ip_product.group_id
           AND PRODUCT.publish = 1
           AND PRODUCT.status_id = v_state.status_id;
        
        UPDATE PRODUCT
           SET PRODUCT.last_record = v_state.last_record,
               PRODUCT.last_action_id = v_state.last_action_id
         WHERE PRODUCT.product_id = v_id_of_last_published;
    ELSE
        INSERT INTO PRODUCT
        VALUES(seq_prod_product_id.NEXTVAL,
             v_product.group_id,
             v_product.product_uid, 
             v_product.product_name, 
             v_product.product_long_name,
             v_product.description, 
             v_product.valid_start_date,
             v_state.status_id,
             v_state.last_action_id,
             v_state.publish,
             v_state.last_record,
             v_state.was_published,
             v_product.comments,
             v_product.active_flag,
             USER,
             CURRENT_DATE,
             v_product.created_by,
             v_product.created_date);
  END IF;
  
  UPDATE PRODUCT
     SET PRODUCT.last_record = 0
   WHERE PRODUCT.product_id = ip_product.product_id;
   
  p_curr_lnk_feat_for_prod(v_product.product_id,v_list_lnk_feature);
    
  FOR i IN v_list_lnk_feature.FIRST..v_list_lnk_feature.LAST
  LOOP
    INSERT INTO LNK_PRODUCT_FEATURE
    VALUES(seq_lnk_prod_feat_id.NEXTVAL,
           seq_prod_product_id.CURRVAL,
           v_list_lnk_feature(i).feature_id,
           v_product.active_flag,
           USER,
           CURRENT_DATE,
           USER,
           CURRENT_DATE);
  END LOOP;
   
   EXCEPTION
    /* **********************************************
     THE PLACE FOR EXCEPTIONS
     ********************************************** */
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(10001/* ERROR CODE */,'You are not able to use this system action with current status of the entity'/* ERROR TEXT */);
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */   
  END p_reject;

  PROCEDURE p_discard(ip_product IN T_PRODUCT) AS
  v_product					           T_PRODUCT;
	v_state   					         T_STATE;
	RETURN_TO_THE_LAST_PUBLISHED BOOLEAN DEFAULT FALSE;
	v_id_of_last_published       NUMBER(5);
  v_list_lnk_feature TBL_LNK_FEATURE;
  BEGIN
    SELECT T_PRODUCT(PRODUCT.product_id,
             PRODUCT.group_id,
             PRODUCT.product_uid,
             PRODUCT.product_name,
             PRODUCT.product_long_name,
             PRODUCT.description,
             PRODUCT.valid_start_date,
             PRODUCT.status_id,
             PRODUCT.last_action_id,
             PRODUCT.publish,
             PRODUCT.last_record,
             PRODUCT.was_published,
             PRODUCT.comments,
             PRODUCT.active_flag,
             PRODUCT.last_modified_by,
             PRODUCT.last_modified_date,
             PRODUCT.created_by,
             PRODUCT.created_date,
             NULL) INTO v_product
      FROM PRODUCT
     WHERE PRODUCT.product_id = ip_product.product_id;
     /* **********************************************
     THE PLACE FOR CHECKS WHICH THROW EXCEPTIONS
     ********************************************** */
     IF SQL%NOTFOUND/* FAILED CHECK */ THEN 
      RAISE NO_DATA_FOUND/* EXCEPTION */;
     END IF;
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */
      IF    v_product.status_id = 1/* PENDING_APPROVAL_ID */ AND v_product.was_published = 0 THEN
            v_state := T_STATE(0,1,0,2/* DISCARDED_ID */,2/* DISCARD */);
      ELSIF v_product.status_id = 1/* PENDING_APPROVAL_ID */ AND v_product.was_published = 1 THEN
            v_state := T_STATE(1,1,1,4/* APPROVED_ID */,2/* DISCARD */);
            RETURN_TO_THE_LAST_PUBLISHED := TRUE;
      ELSIF v_product.status_id = 1/* PENDING_APPROVAL_ID */ AND v_product.was_published = 1 THEN
            v_state := T_STATE(1,1,1,6/* DEACTIVATED_ID */,2/* DISCARD */);
            RETURN_TO_THE_LAST_PUBLISHED := TRUE;
      ELSIF v_product.status_id = 4/* APPROVED_ID */ THEN
            v_state := T_STATE(0,1,1,1/* PENDING_APPROVAL_ID */,2/* DISCARD */);
      END IF;
      
      IF RETURN_TO_THE_LAST_PUBLISHED THEN
          SELECT PRODUCT.product_id INTO v_id_of_last_published
            FROM PRODUCT
           WHERE PRODUCT.group_id  = ip_product.group_id
             AND PRODUCT.publish = 1
             AND PRODUCT.status_id = v_state.status_id;
		
          UPDATE PRODUCT
             SET PRODUCT.last_record = v_state.last_record,
                 PRODUCT.last_action_id = v_state.last_action_id
           WHERE PRODUCT.product_id = v_id_of_last_published;
	ELSE
        INSERT INTO PRODUCT
        VALUES(seq_prod_product_id.NEXTVAL,
               v_product.group_id,
               v_product.product_uid, 
               v_product.product_name, 
               v_product.product_long_name,
               v_product.description, 
               v_product.valid_start_date,
               v_state.status_id,
               v_state.last_action_id,
               v_state.publish,
               v_state.last_record,
               v_state.was_published,
               v_product.comments,
               v_product.active_flag,
               USER,
               CURRENT_DATE,
               v_product.created_by,
               v_product.created_date);
	END IF;
	
	UPDATE PRODUCT
	   SET PRODUCT.last_record = 0
	 WHERE PRODUCT.product_id = ip_product.product_id;
  
  p_curr_lnk_feat_for_prod(v_product.product_id,v_list_lnk_feature);
    
  FOR i IN v_list_lnk_feature.FIRST..v_list_lnk_feature.LAST
  LOOP
    INSERT INTO LNK_PRODUCT_FEATURE
    VALUES(seq_lnk_prod_feat_id.NEXTVAL,
           seq_prod_product_id.CURRVAL,
           v_list_lnk_feature(i).feature_id,
           v_product.active_flag,
           USER,
           CURRENT_DATE,
           USER,
           CURRENT_DATE);
  END LOOP;
  
    EXCEPTION
    /* **********************************************
     THE PLACE FOR EXCEPTIONS
     ********************************************** */
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(10001/* ERROR CODE */,'You are not able to use this system action with current status of the entity'/* ERROR TEXT */);
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */   
  
  END p_discard;

  PROCEDURE p_deactivate(ip_product IN T_PRODUCT) AS
  v_product T_PRODUCT;
	v_state   T_STATE;
  v_list_lnk_feature TBL_LNK_FEATURE;
  BEGIN
    SELECT T_PRODUCT(PRODUCT.product_id,
					 PRODUCT.group_id,
					 PRODUCT.product_uid,
					 PRODUCT.product_name,
					 PRODUCT.product_long_name,
					 PRODUCT.description,
					 PRODUCT.valid_start_date,
					 PRODUCT.status_id,
					 PRODUCT.last_action_id,
					 PRODUCT.publish,
					 PRODUCT.last_record,
					 PRODUCT.was_published,
					 PRODUCT.comments,
					 PRODUCT.active_flag,
					 PRODUCT.last_modified_by,
					 PRODUCT.last_modified_date,
					 PRODUCT.created_by,
					 PRODUCT.created_date,
					 NULL) INTO v_product
	  FROM PRODUCT
	 WHERE PRODUCT.product_id = ip_product.product_id;
    /* **********************************************
     THE PLACE FOR CHECKS WHICH THROW EXCEPTIONS
     ********************************************** */
     IF SQL%NOTFOUND/* FAILED CHECK */ THEN 
      RAISE NO_DATA_FOUND/* EXCEPTION */;
     END IF;
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */
     IF v_product.status_id = 5/* PENDING_DEACTIVATION_ID */ THEN
		v_state := T_STATE(1,1,1,6/* DEACTIVATED_ID */,7/* DEACTIVATE */);
	END IF;
	
	INSERT INTO PRODUCT
	VALUES(seq_prod_product_id.NEXTVAL,
         v_product.group_id,
         v_product.product_uid, 
         v_product.product_name, 
         v_product.product_long_name,
         v_product.description, 
         v_product.valid_start_date,
         v_state.status_id,
         v_state.last_action_id,
         v_state.publish,
         v_state.last_record,
         v_state.was_published,
         v_product.comments,
         v_product.active_flag,
         USER,
         CURRENT_DATE,
         v_product.created_by,
         v_product.created_date);
	
	UPDATE PRODUCT
	   SET PRODUCT.last_record = 0
	 WHERE PRODUCT.product_id = ip_product.product_id;
  
   p_curr_lnk_feat_for_prod(v_product.product_id,v_list_lnk_feature);
    
  FOR i IN v_list_lnk_feature.FIRST..v_list_lnk_feature.LAST
  LOOP
    INSERT INTO LNK_PRODUCT_FEATURE
    VALUES(seq_lnk_prod_feat_id.NEXTVAL,
           seq_prod_product_id.CURRVAL,
           v_list_lnk_feature(i).feature_id,
           v_product.active_flag,
           USER,
           CURRENT_DATE,
           USER,
           CURRENT_DATE);
  END LOOP;
  
   EXCEPTION
    /* **********************************************
     THE PLACE FOR EXCEPTIONS
     ********************************************** */
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(10001/* ERROR CODE */,'You are not able to use this system action with current status of the entity'/* ERROR TEXT */);
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */   
  END p_deactivate;

  PROCEDURE p_reactivate(ip_product IN T_PRODUCT) AS
  v_product T_PRODUCT;
	v_state   T_STATE;
  v_list_lnk_feature TBL_LNK_FEATURE;
  BEGIN
    SELECT T_PRODUCT(PRODUCT.product_id,
					 PRODUCT.group_id,
					 PRODUCT.product_uid,
					 PRODUCT.product_name,
					 PRODUCT.product_long_name,
					 PRODUCT.description,
					 PRODUCT.valid_start_date,
					 PRODUCT.status_id,
					 PRODUCT.last_action_id,
					 PRODUCT.publish,
					 PRODUCT.last_record,
					 PRODUCT.was_published,
					 PRODUCT.comments,
					 PRODUCT.active_flag,
					 PRODUCT.last_modified_by,
					 PRODUCT.last_modified_date,
					 PRODUCT.created_by,
					 PRODUCT.created_date,
					 NULL) INTO v_product
	  FROM PRODUCT
	 WHERE PRODUCT.product_id = ip_product.product_id;
    /* **********************************************
     THE PLACE FOR CHECKS WHICH THROW EXCEPTIONS
     ********************************************** */
     IF SQL%NOTFOUND/* FAILED CHECK */ THEN 
      RAISE NO_DATA_FOUND/* EXCEPTION */;
     END IF;
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */
     IF v_product.status_id = 6/* DEACTIVATED_ID */ THEN
		v_state := T_STATE(0,1,1,1/* PENDING_APPROVAL_ID */,7/* REACTIVATE */);
	END IF;
	
	INSERT INTO PRODUCT
	VALUES(seq_prod_product_id.NEXTVAL,
		   v_product.group_id,
		   v_product.product_uid, 
		   v_product.product_name, 
		   v_product.product_long_name,
		   v_product.description, 
		   v_product.valid_start_date,
		   v_state.status_id,
		   v_state.last_action_id,
		   v_state.publish,
		   v_state.last_record,
		   v_state.was_published,
		   v_product.comments,
		   v_product.active_flag,
		   USER,
		   CURRENT_DATE,
		   v_product.created_by,
		   v_product.created_date);
	
	UPDATE PRODUCT
	   SET PRODUCT.last_record = 0
	 WHERE PRODUCT.product_id = ip_product.product_id;
   
    p_curr_lnk_feat_for_prod(v_product.product_id,v_list_lnk_feature);
    
  FOR i IN v_list_lnk_feature.FIRST..v_list_lnk_feature.LAST
  LOOP
    INSERT INTO LNK_PRODUCT_FEATURE
    VALUES(seq_lnk_prod_feat_id.NEXTVAL,
           seq_prod_product_id.CURRVAL,
           v_list_lnk_feature(i).feature_id,
           v_product.active_flag,
           USER,
           CURRENT_DATE,
           USER,
           CURRENT_DATE);
  END LOOP;
   
   EXCEPTION
    /* **********************************************
     THE PLACE FOR EXCEPTIONS
     ********************************************** */
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(10001/* ERROR CODE */,'You are not able to use this system action with current status of the entity'/* ERROR TEXT */);
    /* **********************************************
     ////////////////////////////////////////////////
     ********************************************** */ 
  END p_reactivate;

END PKG_PRODUCT;
