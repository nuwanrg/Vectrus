select * from PROJECT_ACTIVITY_CLASS_ACT;

select * from PROJECT_ACTIVITY_CLASS_ACT_TAB;


      SELECT *
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id = '479'
      AND    row_state = 2
      ORDER BY row_no;


GRANT EXECUTE ON Vec_Ext_Proj_Util_API TO IFSSYS;


select * from PROJECT_ACTIVITY_CLASS_ACT where activity_seq in (SELECT activity_seq FROM ACTIVITY_EXT_WITHOUT_ACCESS WHERE PROJECT_ID = 'IN000001') ORDER BY ACTIVITY_SEQ DESC; -- ;  -- 100000006 not in the databse 100000616

SELECT * FROM ACTIVITY_EXT_WITHOUT_ACCESS WHERE PROJECT_ID = 'IN000001';
SELECT * from EXT_FILE_LOAD;

select * from Ext_Load_Info_tab order by load_file_id desc; --= '550';

select * from EXT_FILE_TRANS where load_file_id = '555';


select * from EXT_FILE_LOAD where load_file_id = '555';

select * from Ext_Inc_Inv_Load_Info_TAB;

--PROJ_TRANS tranferred
