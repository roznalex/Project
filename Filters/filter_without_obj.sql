
CREATE TYPE Varchar_tab IS TABLE OF VARCHAR2(200);
/
CREATE TYPE Integer_tab IS TABLE OF INTEGER;

/

CREATE OR REPLACE PROCEDURE get_latestrec_for_f (value_out OUT SYS_REFCURSOR) IS
    v_sql VARCHAR2(1000);
BEGIN
    v_sql := 'SELECT * FROM Feature WHERE last_record = 1'
    OPEN value_out FOR v_sql;
    CLOSE value_out;
END get_latestrec_for_f;
/
CREATE OR REPLACE PROCEDURE get_latestrec_for_p (value_out OUT SYS_REFCURSOR) IS
    v_sql VARCHAR2(1000);
BEGIN
    v_sql := 'SELECT * FROM Product WHERE last_record = 1'
    OPEN value_out FOR v_sql;
    CLOSE value_out;
END get_latestrec_for_p;
/
CREATE OR REPLACE PROCEDURE all_active (value_out OUT Varchar_tab) IS
BEGIN
    EXECUTE IMMEDIATE
    'SELECT '
    || 'status_name'
    || ' FROM '
    || Status
    || ' WHERE '
    || 'active_flag = 1'
    BULK COLLECT INTO value_out;
END all_active;
/
CREATE OR REPLACE PROCEDURE all_active_from_la(value_out OUT SYS_REFCURSOR) IS
    v_sql VARCHAR2(1000);
BEGIN
    v_sql := 'SELECT * FROM Last_action WHERE active_flag = 1'
    OPEN value_out FOR v_sql;
    CLOSE value_out;
END all_active_from_la;
/
CREATE OR REPLACE PROCEDURE get_all_users(from_in IN VARCHAR2,
                                value_out OUT Varchar_tab) IS
BEGIN
    EXECUTE IMMEDIATE
    'SELECT DISTINCT '
    || 'last_modified_by'
    || ' FROM '
    || from_in
    BULK COLLECT INTO value_out;
END get_all_users;
/
CREATE OR REPLACE PROCEDURE get_active_fts(value_out OUT Varchar_tab) IS
BEGIN
    EXECUTE IMMEDIATE
    'SELECT '
    || 'feature_type_name'
    || ' FROM '
    || 'Feature_type'
    || ' WHERE '
    || 'active_flag = 1'
    BULK COLLECT INTO value_out;
END get_active_fts;
/
CREATE OR REPLACE PROCEDURE get_uq_fvs(value_out OUT Varchar_tab) IS
BEGIN
    EXECUTE IMMEDIATE
    'SELECT DISTINCT '
    || 'feature_value'
    || ' FROM '
    || 'Feature'
    BULK COLLECT INTO value_out;
END get_uq_fvs;
/
CREATE OR REPLACE PROCEDURE get_uq_gids(value_out OUT Integer_tab) IS
BEGIN
    EXECUTE IMMEDIATE
    'SELECT DISTINCT '
    || 'group_id'
    || ' FROM '
    || 'Feature'
    BULK COLLECT INTO value_out;
END get_uq_gids;
/
CREATE OR REPLACE PROCEDURE get_uq_gids(value_out OUT Integer_tab) IS
BEGIN
    EXECUTE IMMEDIATE
    'SELECT DISTINCT '
    || 'group_id'
    || ' FROM '
    || 'Product'
    BULK COLLECT INTO value_out;
END get_uq_gids;
/
CREATE OR REPLACE PROCEDURE get_uq_names(value_out OUT Varchar_tab, length_in IN VARCHAR2) IS
BEGIN
    IF length_in = 'short' THEN
        EXECUTE IMMEDIATE
        'SELECT DISTINCT '
        || 'product_name'
        || ' FROM '
        || 'Product'
        BULK COLLECT INTO value_out;
    ELSE
        EXECUTE IMMEDIATE
        'SELECT DISTINCT '
        || 'product_long_name'
        || ' FROM '
        || 'Product'
        BULK COLLECT INTO value_out;
    END IF;
END get_uq_names;
/
CREATE OR REPLACE PROCEDURE get_fvs_from_product(value_out OUT Varchar_tab) IS
BEGIN
    EXECUTE IMMEDIATE
    'SELECT '
    || 'feature_value'
    || ' FROM '
    || 'Feature'
    || ' WHERE '
    || 'feature_id EXISTS (SELECT feature_id
                            FROM LNK_Product_Feature)'
    BULK COLLECT INTO value_out;
END get_fvs_from_product;
/
CREATE OR REPLACE PROCEDURE f_filter ( publish IN NUMBER,
                                        linked IN NUMBER(,
                                        latestrecord IN NUMBER,
                                        status_multiselect IN Varchar_tab,
                                        last_action IN VARCHAR2,
                                        users IN Varchar_tab,
                                        feature_type IN VARCHAR2,
                                        feature_value IN VARCHAR2,
                                        feature_id IN INTEGER,
                                        cur_out OUT SYS_REFCURSOR)
IS

    l_feature_piece Feature%ROWTYPE;
    v_sql VARCHAR2(32767);
    v_temp VARCHAR2(1000);

BEGIN

    IF latestrecord = 1 THEN
        latestrec(l_feature_piece);
        OPEN cur_out FOR l_feature_piece;
        CLOSE cur_out;
    ELSE
        v_sql := 'SELECT T_FEATURE';
        v_sql := v_sql || 'FROM Feature';
        v_sql := v_sql || 'WHERE ';

        IF publish IS NOT NULL THEN
            v_sql := v_sql || 'publish = '
                            || publish || ' AND ';
        END IF;

        IF linked IS NOT NULL THEN
            v_sql := v_sql || 'linked = '
                            || linked || ' AND ';
        END IF;

        IF status_multiselect IS NOT NULL THEN
            v_temp := '(';
            FOR idx IN status_multiselect.FIRST..(status_multiselect.LAST - 1)
            LOOP
                v_temp := v_temp || status_multiselect(idx) || ',';
            END LOOP;
            v_temp := v_temp || status_multiselect(status_multiselect.LAST) || ')';

            v_sql := v_sql || 'status_id IN (SELECT status_id FROM Status WHERE status_name IN '
                            || v_temp || ') AND ';
        END IF;

        IF last_action IS NOT NULL THEN
            v_sql := v_sql || 'last_action_id =
                                (SELECT last_action_id FROM Last_action WHERE last_action_name = '
                                || last_action || ') AND ';
        END IF;

        IF users IS NOT NULL THEN
            v_temp := '(';
            FOR idx IN users.FIRST..(users.LAST - 1)
            LOOP
                v_temp := v_temp || user(idx) || ',';
            END LOOP;
            v_temp := v_temp || users(users.LAST) || ')';

            v_sql := v_sql || 'last_modified_by IN ' || v_temp || ' AND ';
        END IF;

        IF feature_type IS NOT NULL THEN
            v_sql := v_sql || 'feature_type_id =
                                (SELECT feature_type_id FROM Feature_type WHERE feature_type_value = '
                                || feature_type || ') AND ';
        END IF;

        IF feature_value IS NOT NULL THEN
            v_sql := v_sql || 'feature_value = ' || feature_value || ' AND ';
        END IF;

        IF feature_id IS NOT NULL THEN
            v_sql := v_sql || 'feature_id = ' || feature_id ;
        END IF;

        OPEN cut_out FOR v_sql;
        CLOSE cur_out;
    END IF;

END;

/
CREATE OR REPLACE PROCEDURE p_filter ( publish IN NUMBER,
                                        latestrecord IN NUMBER,
                                        status_multiselect IN Varchar_tab,
                                        last_action IN VARCHAR2,
                                        users IN Varchar_tab,
                                        feature_value IN VARCHAR2,
                                        product_uid IN INTEGER,
                                        product_name IN VARCHAR2,
                                        product_long_name IN VARCHAR2,
                                        cur_out OUT SYS_REFCURSOR)
IS

    l_product_piece Product%ROWTYPE;
    v_sql VARCHAR2(32767);
    v_temp VARCHAR2(1000);

BEGIN

    IF latestrecord = 1 THEN
        latestrec(l_product_piece);
        OPEN cur_out FOR l_product_piece;
        CLOSE cur_out;
    ELSE
        v_sql := 'SELECT T_PRODUCT';
        v_sql := v_sql || 'FROM Product';
        v_sql := v_sql || 'WHERE ';

        IF publish IS NOT NULL THEN
            v_sql := v_sql || 'publish = '
                            || publish || ' AND ';
        END IF;

        IF status_multiselect IS NOT NULL THEN
            v_temp := '(';
            FOR idx IN status_multiselect.FIRST ..
                    (status_multiselect.LAST - 1)
            LOOP
                v_temp := v_temp || status_multiselect(idx) || ',';
            END LOOP;
            v_temp := v_temp || status_multiselect(status_multiselect.LAST) || ')';

            v_sql := v_sql || 'status_id IN (SELECT status_id FROM Status WHERE status_name IN '
                            || v_temp || ') AND ';
        END IF;

        IF last_action IS NOT NULL THEN
            v_sql := v_sql || 'last_action_id =
                                (SELECT last_action_id FROM Last_action WHERE last_action_name = '
                                || last_action || ') AND ';
        END IF;

        IF users IS NOT NULL THEN
            v_temp := '(';
            FOR idx IN users.FIRST ..
                    (users.LAST - 1)
            LOOP
                v_temp := v_temp || users(idx) || ',';
            END LOOP;
            v_temp := v_temp || users(users.LAST) || ')';

            v_sql := v_sql || 'last_modified_by IN ' || v_temp || ' AND ';
        END IF;

        IF product_uid IS NOT NULL THEN
            v_sql := v_sql || 'product_uid = ' || product_uid || ' AND ';
        END IF;

        IF product_name IS NOT NULL THEN
            v_sql := v_sql || 'product_name = ' || product_name || ' AND ';
        END IF;

        IF product_long_name IS NOT NULL THEN
            v_sql := v_sql || 'product_long_name = ' || product_long_name || ' AND ';
        END IF;

        IF feature_value IS NOT NULL THEN
            v_sql := v_sql || 'product_id IN (SELECT product_id FROM LNK_Product_Feature WHERE
                                feature_id = (SELECT feature_id FROM Feature WHERE feature_value = '
                                    || feature_value || '))';
        END IF;

        OPEN cut_out FOR v_sql;
        CLOSE cur_out;
    END IF;

END;
