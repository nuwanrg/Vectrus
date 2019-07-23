create or replace package Vec_Ext_Proj_Util_API is

module_                   CONSTANT VARCHAR2(6)      := 'PROJ';
lu_name_                  CONSTANT VARCHAR2(30)     := 'ProjectActivityClassAct';
lu_type_                  CONSTANT VARCHAR2(30)     := 'Utility';

PROCEDURE Start_Ext_Activity_Class (
   info_             IN OUT NOCOPY VARCHAR2,
   load_file_id_     IN     NUMBER,
   parameter_string_ IN     VARCHAR2 DEFAULT NULL );
   
   --@PoReadOnly(Init)
PROCEDURE Init;

end Vec_Ext_Proj_Util_API;
/
create or replace package body Vec_Ext_Proj_Util_API is

PROCEDURE Start_Ext_Activity_Class (
   info_             IN OUT NOCOPY VARCHAR2,
   load_file_id_     IN     NUMBER,
   parameter_string_ IN     VARCHAR2 DEFAULT NULL )
IS
   
   PROCEDURE Core (
      info_             IN OUT NOCOPY VARCHAR2,
      load_file_id_     IN     NUMBER,
      parameter_string_ IN     VARCHAR2 DEFAULT NULL )
   IS
      ext_file_load_rec_    Ext_File_Load_API.Public_Rec;
      rec_                  Ext_transactions_API.ExtTransRec;
      objid_                   VARCHAR(100);
      objversion_              VARCHAR(100);
      attr_                    VARCHAR(2000);
      activity_seq_            NUMBER;
      activity_class_seq_      NUMBER;
      activity_class_id_       VARCHAR2(100);
      value_                   VARCHAR2(100);
      err_msg_              VARCHAR2(2000);
      line_no_              NUMBER := 0;

      
      CURSOR get_ext_file_trans IS
      SELECT *
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id = load_file_id_
      AND    row_state = 2
      ORDER BY row_no;
      
	CURSOR get_load_id IS
	SELECT company,
	load_id
	FROM   Ext_Load_Info_Tab
	WHERE  load_file_id = load_file_id_;
      
      CURSOR get_activity_class_id (activity_class_seq_      NUMBER) IS      
      SELECT activity_class_id ,
      description
      validity,
      project_id 
      FROM project_activity_class_lov
      WHERE (Project_Activity_Class_API.Is_Class_Valid_Var ( activity_class_seq_,activity_class_seq) = 'TRUE') 
      order by ACTIVITY_CLASS_ID;
      
      activity_class_id_rec get_activity_class_id%ROWTYPE ;
     
   BEGIN
      dbms_output.put_line('yeeeeeeeeeeeee');
      --ext_file_load_rec_ := Ext_File_load_file_id_Load_API.Get ();
       ext_file_load_rec_ := Ext_File_Load_API.Get (load_file_id_);
      
       FOR trans_rec_ IN get_ext_file_trans LOOP
         
            BEGIN
                rec_.load_file_id                   := load_file_id_;
                rec_.row_no                         := trans_rec_.row_no;
                activity_seq_ := trans_rec_.N1;
                activity_class_seq_ := trans_rec_.N2;
                value_        := trans_rec_.c1;
                            
                OPEN get_activity_class_id (activity_class_seq_ );
                FETCH get_activity_class_id INTO activity_class_id_rec;
                CLOSE get_activity_class_id;
                                     
                dbms_output.put_line('activity_seq_ : ' || activity_seq_);
                dbms_output.put_line('activity_class_seq_ : ' || activity_class_seq_);
                dbms_output.put_line('value_ : ' || value_);
                                        
                info_ := NULL;
                objid_      := NULL;
                objversion_ := NULL;
                Client_SYS.Clear_Attr(attr_);
                Project_Activity_Class_Act_API.New__(info_, objid_, objversion_, attr_, 'PREPARE' );
                Client_SYS.Add_To_Attr('ACTIVITY_SEQ',activity_seq_, attr_);
                Client_SYS.Add_To_Attr('ACTIVITY_CLASS_ID',activity_class_id_rec.activity_class_id, attr_);            
                Client_SYS.Add_To_Attr('ACTIVITY_CLASS_SEQ',activity_class_seq_, attr_);
                Client_SYS.Add_To_Attr('VALUE',value_, attr_);

                Project_Activity_Class_Act_API.New__(info_, objid_, objversion_, attr_, 'DO' );
                
                line_no_ := line_no_ +1;
                Ext_File_Trans_API.Update_Row_State (load_file_id_,
                                                 trans_rec_.row_no,
                                                 '3');
                  
            EXCEPTION
                WHEN OTHERS THEN
                  err_msg_ := SQLERRM;
                Ext_File_Trans_API.Update_Row_State (load_file_id_,
                                              rec_.row_no,
                                              '5',
                                              err_msg_);
          
            END;

       END LOOP;
       
      IF (line_no_ = 0) THEN
         Error_Sys.Record_General(lu_name_,'NOUNPDATA: No unpacked data found, check load file id :P1',load_file_id_);
      ELSE
          Ext_File_Load_API.Update_State (load_file_id_, '4');
          info_ := Client_SYS.Get_All_Info;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         Ext_File_Load_API.Update_State (load_file_id_, '9');   

   END Core;

BEGIN
   General_SYS.Init_Method(Vec_Ext_Proj_Util_API.lu_name_, 'Vec_Ext_Proj_Util_API', 'Start_Ext_Activity_Class');
   Core(info_, load_file_id_, parameter_string_);
END Start_Ext_Activity_Class;


-----------------------------------------------------------------------------
-------------------- FOUNDATION1 METHODS ------------------------------------
-----------------------------------------------------------------------------


--@IgnoreMissingSysinit
PROCEDURE Init
IS
   
   PROCEDURE Base
   IS
   BEGIN
      NULL;
   END Base;

BEGIN
   Base;
END Init;

BEGIN
   Init;

end Vec_Ext_Proj_Util_API;
/
