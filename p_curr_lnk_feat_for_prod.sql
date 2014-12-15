PROCEDURE p_curr_lnk_feat_for_prod(ip_product_id IN NUMBER, iop_lnk_feature_id IN OUT TBL_LNK_FEATURE) AS
	CURSOR c_lnk_feat_for_prod(product_id NUMBER) IS
		SELECT lnk.feature_id
		  FROM LNK_PRODUCT_FEATURE lnk
		 WHERE lnk.product_id = product_id;
	v_count INT;
BEGIN
	v_count := 1;
	
	FOR cursor_feature_id IN c_lnk_feat_for_prod
	LOOP
		iop_lnk_feature_id(v_count).feature_id := cursor_feature_id;
		v_count := v_count + 1;
	END LOOP;
END p_curr_lnk_feat_for_prod;