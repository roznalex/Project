
CREATE TYPE Varchar_tab IS TABLE OF VARCHAR2(200);

CREATE OR REPLACE TYPE grid_filter_obj AS (
    publish SIGNTYPE,
    linked SIGNTYPE,
    latestrecord SIGNTYPE,
    MEMBER PROCEDURE get_latestrec(l_value OUT Grid%ROWTYPE),
    status_multiselect Varchar_tab,
    MEMBER PROCEDURE get_all_active_stat(l_value OUT Varchar_tab),
    --user--
)

CREATE OR REPLACE TYPE BODY grid_filter_obj AS
    MEMBER PROCEDURE get_latestrec (l_value OUT Grid%ROWTYPE)
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT *'
        || ' FROM '
        || Grid
        || ' WHERE '
        || 'last_record = 1'
        INTO l_value
    END latestrec;
    MEMBER PROCEDURE all_active (l_values OUT Varchar_tab)
    BEGIN
        EXECUTE IMMEDIATE
        'SELECT '
        || status_name
        || ' FROM '
        || Status
        || ' WHERE '
        || 'active_flag = 1'
        BULK COLLECT INTO l_values;
    END all_active;

END;

CREATE OR REAPLACE PROCDURE
grid_filter (
    filter_obj IN grid_filter_obj,
    cur IN OUT REF_SYSCURSOR)
IS
    TYPE grid_piece IS TABLE OF Grid%ROWTYPE;
    l_values grid_piece;
    idx INTEGER := 1;
BEGIN
    IF filter_obj.lastrecord = 1 THEN
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

END;
