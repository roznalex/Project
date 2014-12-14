CREATE TABLE   LNK_PRODUCT_FEATURE (
lnk_product_feature_id       number(5),
product_id                   number(5),
feature_id                   number(5),
active_flag                  number(1),
last_modified_by             varchar2(200),
last_modified_date           timestamp(6) with local time zone,
created_by                   varchar2(200),
created_date                 timestamp(6)  with local time zone
;


ALTER TABLE LNK_PRODUCT_FEATURE
ADD CONSTRAINT pk_lnk_prod_feat   				primary key    ( lnk_product_feature_id ) ; 

ALTER TABLE LNK_PRODUCT_FEATURE
ADD CONSTRAINT ch_lnk_prod_feat_active_flag     check          ( active_flag in (0,1) );

ALTER TABLE LNK_PRODUCT_FEATURE
ADD CONSTRAINT fk_lnk_prod_feat_product_id    	foreign key    ( product_id )
REFERENCES   Product    (product_id);

ALTER TABLE LNK_PRODUCT_FEATURE
ADD CONSTRAINT fk_lnk_prod_feat_feature_id   	foreign key    ( feature_id )
REFERENCES   Feature  (feature_id);
