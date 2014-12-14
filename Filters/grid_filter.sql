
CREATE TYPE Varchar_tab IS TABLE OF VARCHAR2(200);
CREATE TYPE Integer_tab IS TABLE OF INTEGER;

CREATE OR REPLACE TYPE filter_obj AS (
    publish             NUMBER(1),
    linked              NUMBER(1),
    latestrecord        NUMBER(1),
    status_multiselect  Varchar_tab,
    user                Varchar_tab,
    MEMBER PROCEDURE get_latestrec(value_out OUT History%ROWTYPE),
    MEMBER PROCEDURE get_active_statuses(value_out OUT Varchar_tab),
    MEMBER PROCEDURE get_last_action(value_out OUT Last_action%ROWTYPE),
    MEMBER PROCEDURE get_all_users(value_out OUT Varchar_tab),
    feature_type_id     INTEGER,
    feature_value       VARCHAR2(200),
    feature_id          INTEGER,
    MEMBER PROCEDURE get_active_fts(value_out OUT Varchar_tab),
    MEMBER PROCEDURE get_uq_fvs(value_out OUT Varchar_tab),
    MEMBER PROCEDURE get_uq_gids(value_out OUT Integer_tab),
    product_uid         INTEGER,
    product_name        VARCHAR2(150),
    product_long_name   VARCHAR2(250),
    MEMBER PROCEDURE get_uq_names(value_out OUT Varcah_tab, length_in IN VARCHAR2(5)),
    MEMBER PROCEDURE get_fvs_from_product(value_out OUT Varcahr_tab),
)

CREATE OR REPLACE TYPE BODY grid_filter_obj AS

    MEMBER PROCEDURE get_latestrec (value_out OUT History%ROWTYPE)
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT *'
        || ' FROM '
        || History
        || ' WHERE '
        || 'last_record = 1'
        INTO value_out
    END latestrec;

    MEMBER PROCEDURE all_active (value_out OUT Varchar_tab)
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT '
        || status_name
        || ' FROM '
        || Status
        || ' WHERE '
        || 'active_flag = 1'
        BULK COLLECT INTO value_out;
    END all_active;

    MEMBER PROCEDURE get_last_action(value_out OUT Last_action%ROWTYPE)
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT *'
        || ' FROM '
        || Last_action
        || ' WHERE '
        || 'last_modified_date = MAX(last_modified_date)'
        INTO value_out
    END get_last_action;

    MEMBER PROCEDURE get_all_users(value_out OUT Varchar_tab)
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT DISTINCT'
        || last_modified_by
        || ' FROM '
        || LNK_Product_Feature
        BULK COLLECT INTO value_out;
    END get_all_users;

    MEMBER PROCEDURE get_active_fts(value_out OUT Varchar_tab)
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT '
        || feature_type_name
        || ' FROM '
        || Feature_type
        || ' WHERE '
        || 'active_flag = 1'
        BULK COLLECT INTO value_out;
    END get_active_fts;

    MEMBER PROCEDURE get_uq_fvs(value_out OUT Varchar_tab)
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT DISTINCT'
        || feature_value
        || ' FROM '
        || Feature
        BULK COLLECT INTO value_out;
    END get_uq_fvs;

    MEMBER PROCEDURE get_uq_gids(value_out OUT Integer_tab)
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT DISTINCT'
        || group_id
        || ' FROM '
        || Feature
        BULK COLLECT INTO value_out;
    END get_ua_gids;

    MEMBER PROCEDURE get_uq_names(value_out OUT Varcah_tab, length_in IN VARCHAR2(5))
    BEGIN
    IF length_in = "short" THEN
        EXECUTE IMMEDIATE
        'SELECT DISTINCT'
        || product_name
        || ' FROM '
        || Product
        BULK COLLECT INTO value_out;
    ELSE
        EXECUTE IMMEDIATE
        'SELECT DISTINCT'
        || product_long_name
        || ' FROM '
        || Product
        BULK COLLECT INTO value_out;
    END get_uq_names;

    MEMBER PROCEDURE get_fvs_from_product(value_out OUT Varcahr_tab)
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT '
        || feature_value
        || ' FROM '
        || Feature
        || ' WHERE '
        || 'feature_id EXISTS (SELECT feature_id
                                FROM LNK_Product_Feature)'
        BULK COLLECT INTO value_out;
    END get_fvs_from_product;

END;

CREATE OR REAPLACE PROCDURE
filter (
    filter_obj_in IN filter_obj,
    cur_out OUT REF_SYSCURSOR)
IS
    TYPE grid_piece IS TABLE OF Grid%ROWTYPE;
    l_values grid_piece;
BEGIN
    /*IF filter_obj.lastrecord = 1 THEN
        filter_obj.get_lastrec(grid_piece(idx));
        OPEN cur FOR SELECT * FROM TABLE(grid_piece);
        CLOSE cur;
    ELSE
        OPEN cur;
        LOOP
            IF (filter_obj.publish IS NULL OR cur.publish = filter_obj.publish) AND
               (filter_obj.linked IS NULL OR cur.linked = filter_obj.linked) AND
               (filter_obj.status_multiselect IS NULL OR filter_obj.status_multiselect.EXISTS(cur.status_name) AND
               (filter_obj.latestrecord IS NULL OR cur.latestrecord = filter_obj.latestrecord)) THEN

                FETCH cur INTO grid_piece(idx);
                EXIT WHEN cur%NOTFOUND;

                idx := idx + 1;
            END IF;
        END LOOP;
        CLOSE cur;
    END IF;

    OPEN cur FOR SELECT * FROM TABLE(grid_piece);
    CLOSE cur;
*/
END;
