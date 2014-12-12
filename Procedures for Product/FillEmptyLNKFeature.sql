CREATE OR REPLACE PROCEDURE p_fill_empty_lnk_feature(ip_lnk_feature IN OUT TBL_LNK_FEATURE) IS
	CURSOR c_def_feature IS
		SELECT FEATURE.feature_id, FEATURE.feature_type_id 
		  FROM FEATURE
		 WHERE FEATURE.active_flag = 1
		   AND FEATURE.is_default = 1
		   AND FEATURE.last_record = 1
		   AND FEATURE.status_id = /* APPROVED */;	 
	
	TYPE TBL_LACK_OF_FEATURE_TYPE AS TABLE OF NUMBER;
	
	v_def_feature          TBL_LNK_FEATURE;
	v_lack_of_feature_type TBL_LACK_OF_FEATURE_TYPE;
	v_sorted1			   TBL_LNK_FEATURE;
	v_sorted2			   TBL_LNK_FEATURE;
	v_difference           TBL_LNK_FEATURE;
BEGIN	 
	/* **********************************************
	 THE PLACE FOR CHECKS WHICH THROW EXCEPTIONS
	 ********************************************** */
	OPEN c_def_feature;
	FOR i IN 1..c_def_feature%ROWCOUNT
	LOOP
		FETCH c_def_feature INTO v_def_feature(i);
	END LOOP;
	CLOSE c_def_feature;
	
	IF ip_lnk_feature.COUNT != v_def_feature.COUNT THEN
		/*SELECT * INTO v_sorted1
		  FROM TABLE(v_def_feature)
		ORDER BY feature_type_id;
		
		SELECT * INTO v_sorted2
		  FROM TABLE(ip_lnk_feature)
		ORDER BY feature_type_id;
		
		FOR i IN v_sorted1.FIRST..v_sorted1.LAST
		LOOP
			IF v_sorted2(i) IS EMPTY THEN
				v_sorted2(i) = v_sorted1(i);
			END IF;
		END LOOP;
		
		ip_lnk_feature := v_sorted2;*/
		
	END IF;

END p_fill_empty_lnk_feature;