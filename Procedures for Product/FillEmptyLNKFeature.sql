CREATE OR REPLACE PROCEDURE p_fill_empty_lnk_feature(ip_lnk_feature IN OUT T_LNK_FEATURE) IS
	CURSOR v_act_def_feature IS
		SELECT FEATURE.feature_id, FEATURE.feature_type_id 
		  FROM FEATURE
		 WHERE FEATURE.active_flag = 1
		   AND FEATURE.is_default = 1
		   AND FEATURE.last_record = 1;
		 
	TYPE T_DESCR_FEATURE AS TABLE OF NUMBER, NUMBER;	 
	v_list_given_feature_type_id  T_DESCR_FEATURE;
	v_list_active_feature_type_id T_DESCR_FEATURE;
	v_list_default_feature_id     T_LNK_FEATURE;
BEGIN	 
	/* **********************************************
	 THE PLACE FOR CHECKS WHICH THROW EXCEPTIONS
	 ********************************************** */
	OPEN v_act_def_feature;
	
	FOR i IN 1..v_act_def_feature%ROWCOUNT
	LOOP
		FETCH v_act_def_feature INTO v_list_active_feature_type_id(i);
	END LOOP;
	
	CLOSE v_act_def_feature;
	
	
	
	FOR i IN ip_lnk_feature.FIRST..ip_lnk_feature.LAST
	LOOP
		v_list_ip_feature_type_id(i) = ;
	END LOOP;
	
	IF ip_lnk_feature.COUNT < v_list_feature_type_id.COUNT THEN
		
	END IF;
	
EXCEPTION

END p_fill_empty_lnk_feature;