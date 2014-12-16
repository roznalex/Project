
CREATE TYPE Varchar_tab IS TABLE OF VARCHAR2(200);
/
CREATE TYPE Integer_tab IS TABLE OF INTEGER;
/
CREATE OR REPLACE TYPE g_filter_obj AS object(
    publish             NUMBER(1),
    linked              NUMBER(1),
    latestrecord        NUMBER(1),
    status_multiselect  Varchar_tab,
    last_action         VARCHAR2(300),
    users               Varchar_tab,
    MEMBER PROCEDURE get_latestrec_for_f(value_out OUT Feature%ROWTYPE),
    MEMBER PROCEDURE get_latestrec_for_p(value_out OUT Product%ROWTYPE),
    MEMBER PROCEDURE get_active_statuses(value_out OUT Varchar_tab),
    MEMBER PROCEDURE get_last_action(value_out OUT Last_action%ROWTYPE),
    MEMBER PROCEDURE get_all_users(from_in IN VARCHAR2, value_out OUT Varchar_tab)
);
/
CREATE OR REPLACE TYPE f_filter_obj AS object (
    grid_filter_obj     g_filter_obj,
    feature_type        VARCHAR2(200),
    feature_value       VARCHAR2(200),
    feature_id          INTEGER,
    MEMBER PROCEDURE get_active_fts(value_out OUT Varchar_tab),
    MEMBER PROCEDURE get_uq_fvs(value_out OUT Varchar_tab),
    MEMBER PROCEDURE get_uq_gids(value_out OUT Integer_tab)
);
/
CREATE OR REPLACE TYPE p_filter_obj AS object(
    grid_filter_obj     g_filter_obj,
    feature_value       VARCHAR2(200),
    product_uid         INTEGER,
    product_name        VARCHAR2(150),
    product_long_name   VARCHAR2(250),
    MEMBER PROCEDURE get_uq_names(value_out OUT Varcah_tab, length_in IN VARCHAR2),
    MEMBER PROCEDURE get_fvs_from_product(value_out OUT Varcahr_tab),
    MEMBER PROCEDURE get_uq_gids(value_out OUT Integer_tab)
);
/
CREATE OR REPLACE TYPE BODY g_filter_obj AS

    MEMBER PROCEDURE get_latestrec_for_f (value_out OUT Feature%ROWTYPE) IS
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT *'
        || ' FROM '
        || Feature
        || ' WHERE '
        || 'last_record = 1'
        INTO value_out;
    END get_latestrec_for_f;

    MEMBER PROCEDURE get_latestrec_for_p (value_out OUT Product%ROWTYPE) IS
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT *'
        || ' FROM '
        || Product
        || ' WHERE '
        || 'last_record = 1'
        INTO value_out;
    END get_latestrec_for_p;

    MEMBER PROCEDURE all_active (value_out OUT Varchar_tab) IS
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

    MEMBER PROCEDURE get_last_action(value_out OUT Last_action%ROWTYPE) IS
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT *'
        || ' FROM '
        || 'Last_action'
        || ' WHERE '
        || 'last_modified_date = MAX(last_modified_date)'
        INTO value_out;
    END get_last_action;

    MEMBER PROCEDURE get_all_users(from_in IN VARCHAR2,
                                    value_out OUT Varchar_tab) IS
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT DISTINCT '
        || 'last_modified_by'
        || ' FROM '
        || from_in
        BULK COLLECT INTO value_out;
    END get_all_users;
END;
/
CREATE OR REPLACE TYPE BODY f_filter_obj AS
    MEMBER PROCEDURE get_active_fts(value_out OUT Varchar_tab) IS
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT '
        || 'feature_type_name'
        || ' FROM '
        || Feature_type
        || ' WHERE '
        || 'active_flag = 1'
        BULK COLLECT INTO value_out;
    END get_active_fts;

    MEMBER PROCEDURE get_uq_fvs(value_out OUT Varchar_tab) IS
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT DISTINCT '
        || 'feature_value'
        || ' FROM '
        || Feature
        BULK COLLECT INTO value_out;
    END get_uq_fvs;

    MEMBER PROCEDURE get_uq_gids(value_out OUT Integer_tab) IS
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT DISTINCT '
        || 'group_id'
        || ' FROM '
        || Feature
        BULK COLLECT INTO value_out;
    END get_uq_gids;
END;
/
CREATE OR REPLACE TYPE BODY p_filter_obj AS
    MEMBER PROCEDURE get_uq_gids(value_out OUT Integer_tab) IS
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT DISTINCT '
        || 'group_id'
        || ' FROM '
        || Product
        BULK COLLECT INTO value_out;
    END get_uq_gids;

    MEMBER PROCEDURE get_uq_names(value_out OUT Varcah_tab, length_in IN VARCHAR2) IS
    BEGIN
        IF length_in = 'short' THEN
            EXECUTE IMMEDIATE
            'SELECT DISTINCT '
            || 'product_name'
            || ' FROM '
            || Product
            BULK COLLECT INTO value_out;
        ELSE
            EXECUTE IMMEDIATE
            'SELECT DISTINCT '
            || 'product_long_name'
            || ' FROM '
            || Product
            BULK COLLECT INTO value_out;
        END IF;
    END get_uq_names;

    MEMBER PROCEDURE get_fvs_from_product(value_out OUT Varcahr_tab) IS
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT '
        || 'feature_value'
        || ' FROM '
        || Feature
        || ' WHERE '
        || 'feature_id EXISTS (SELECT feature_id
                                FROM LNK_Product_Feature)'
        BULK COLLECT INTO value_out;
    END get_fvs_from_product;

END;
/
CREATE OR REPLACE PROCEDURE f_filter ( f_filter_obj_in IN f_filter_obj,
                                        cur_out OUT SYS_REFCURSOR)
IS

    l_feature_piece Feature%ROWTYPE;
    v_sql VARCHAR2(32767);
    v_temp VARCHAR2(1000);

BEGIN

    IF f_filter_obj_in.g_filter_obj.latestrecord = 1 THEN
        f_ilter_obj_in.g_filter_obj.latestrec(l_feature_piece);
        OPEN cur_out FOR l_feature_piece;
        CLOSE cur_out;
    ELSE
        v_sql := 'SELECT T_FEATURE';
        v_sql := v_sql || 'FROM Feature';
        v_sql := v_sql || 'WHERE ';

        IF f_filter_obj_in.g_filter_obj.publish IS NOT NULL THEN
            v_sql := v_sql || 'publish = '
                            || f_filter_obj_in.g_filter_obj.publish || ' AND ';
        END IF;

        IF f_filter_obj_in.g_filter_obj.linked IS NOT NULL THEN
            v_sql := v_sql || 'linked = '
                            || f_filter_obj_in.g_filter_obj.linked || ' AND ';
        END IF;

        IF f_filter_obj_in.g_filter_obj.status_multiselect IS NOT NULL THEN
            v_temp := '(';
            FOR idx IN f_filter_obj_in.g_filter_obj.status_multiselect.FIRST ..
                    (f_filter_obj_in.g_filter_obj.status_multiselect.LAST - 1)
            LOOP
                v_temp := v_temp || f_filter_obj_in.g_filter_obj.status_multiselect(idx) || ',';
            END LOOP;
            v_temp := v_temp || f_filter_obj_in.g_filter_obj.status_multiselect(f_filter_obj_in.g_filter_obj.status_multiselect.LAST) || ')';

            v_sql := v_sql || 'status_id IN (SELECT status_id FROM Status WHERE status_name IN ' || v_temp || ') AND ';
        END IF;

        IF f_filter_obj_in.g_filter_obj.last_action IS NOT NULL THEN
            v_sql := v_sql || 'last_action_id =
                                (SELECT last_action_id FROM Last_action WHERE last_action_name = '
                                || f_filter_obj_in.g_filter_obj.last_action || ') AND ';
        END IF;

        IF f_filter_obj_in.g_filter_obj.users IS NOT NULL THEN
            v_temp := '(';
            FOR idx IN f_filter_obj_in.g_filter_obj.users.FIRST ..
                        (f_filter_obj_in.g_filter_obj.users.LAST - 1)
            LOOP
                v_temp := v_temp || f_filter_obj_in.g_filter_obj.user(idx) || ',';
            END LOOP;
            v_temp := v_temp || f_filter_obj_in.g_filter_obj.users(f_filter_obj_in.g_filter_obj.users.LAST) || ')';

            v_sql := v_sql || 'last_modified_by IN ' || v_temp || ' AND ';
        END IF;

        IF f_filter_obj_in.feature_type IS NOT NULL THEN
            v_sql := v_sql || 'feature_type_id =
                                (SELECT feature_type_id FROM Feature_type WHERE feature_type_value = '
                                || f_filter_obj_in.feature_type || ') AND ';
        END IF;

        IF f_filter_obj_in.feature_value IS NOT NULL THEN
            v_sql := v_sql || 'feature_value = ' || f_filter_obj_in.feature_value || ' AND ';
        END IF;

        IF f_filter_obj_in.feature_id IS NOT NULL THEN
            v_sql := v_sql || 'feature_id = ' || f_filter_obj_in.feature_id ;
        END IF;

        OPEN cut_out FOR v_sql;
        CLOSE cur_out;
    END IF;

END;

/
CREATE OR REPLACE PROCEDURE p_filter ( p_filter_obj_in IN p_filter_obj,
                                        cur_out OUT SYS_REFCURSOR)
IS

    l_product_piece Product%ROWTYPE;
    v_sql VARCHAR2(32767);
    v_temp VARCHAR2(1000);

BEGIN

    IF p_filter_obj_in.g_filter_obj.latestrecord = 1 THEN
        p_ilter_obj_in.g_filter_obj.latestrec(l_product_piece);
        OPEN cur_out FOR l_product_piece;
        CLOSE cur_out;
    ELSE
        v_sql := 'SELECT T_PRODUCT';
        v_sql := v_sql || 'FROM Product';
        v_sql := v_sql || 'WHERE ';

        IF p_filter_obj_in.g_filter_obj.publish IS NOT NULL THEN
            v_sql := v_sql || 'publish = '
                            || p_filter_obj_in.g_filter_obj.publish || ' AND ';
        END IF;

        IF p_filter_obj_in.g_filter_obj.linked IS NOT NULL THEN
            v_sql := v_sql || 'linked = '
                            || p_filter_obj_in.g_filter_obj.linked || ' AND ';
        END IF;

        IF p_filter_obj_in.g_filter_obj.status_multiselect IS NOT NULL THEN
            v_temp := '(';
            FOR idx IN p_filter_obj_in.g_filter_obj.status_multiselect.FIRST ..
                    (p_filter_obj_in.g_filter_obj.status_multiselect.LAST - 1)
            LOOP
                v_temp := v_temp || p_filter_obj_in.g_filter_obj.status_multiselect(idx) || ',';
            END LOOP;
            v_temp := v_temp || p_filter_obj_in.g_filter_obj.status_multiselect(p_filter_obj_in.g_filter_obj.status_multiselect.LAST) || ')';

            v_sql := v_sql || 'status_id IN (SELECT status_id FROM Status WHERE status_name IN ' || v_temp || ') AND ';
        END IF;

        IF p_filter_obj_in.g_filter_obj.last_action IS NOT NULL THEN
            v_sql := v_sql || 'last_action_id =
                                (SELECT last_action_id FROM Last_action WHERE last_action_name = '
                                || p_filter_obj_in.g_filter_obj.last_action || ') AND ';
        END IF;

        IF p_filter_obj_in.g_filter_obj.users IS NOT NULL THEN
            v_temp := '(';
            FOR idx IN p_filter_obj_in.g_filter_obj.users.FIRST ..
                    (p_filter_obj_in.g_filter_obj.users.LAST - 1)
            LOOP
                v_temp := v_temp || p_filter_obj_in.g_filter_obj.users(idx) || ',';
            END LOOP;
            v_temp := v_temp || p_filter_obj_in.g_filter_obj.users(p_filter_obj_in.g_filter_obj.users.LAST) || ')';

            v_sql := v_sql || 'last_modified_by IN ' || v_temp || ' AND ';
        END IF;

        IF p_filter_obj_in.product_uid IS NOT NULL THEN
            v_sql := v_sql || 'product_uid = ' || p_filter_obj_in.product_uid || ' AND ';
        END IF;

        IF p_filter_obj_in.product_name IS NOT NULL THEN
            v_sql := v_sql || 'product_name = ' || p_filter_obj_in.product_name || ' AND ';
        END IF;

        IF p_filter_obj_in.product_long_name IS NOT NULL THEN
            v_sql := v_sql || 'product_long_name = ' || p_filter_obj_in.product_long_name || ' AND ';
        END IF;

        IF p_filter_obj_in.feature_value IS NOT NULL THEN
            v_sql := v_sql || 'product_id IN (SELECT product_id FROM LNK_Product_Feature WHERE
                                feature_id = (SELECT feature_id FROM Feature WHERE feature_value = ' || p_filter_obj_in.feature_value || '))';
        END IF;

        OPEN cut_out FOR v_sql;
        CLOSE cur_out;
    END IF;

END;
