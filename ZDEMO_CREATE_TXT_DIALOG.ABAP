*&---------------------------------------------------------------------*
*& Report ZDEMO_CREATE_TXT_DIALOG
*&---------------------------------------------------------------------*
*& DESCRIPTION: Create file on the local system with dialog
*&---------------------------------------------------------------------*
REPORT zdemo_create_txt_dialog.

DATA: d_itab TYPE TABLE OF string.
DATA: d_xtab TYPE string.

DATA:
  BEGIN OF fs_vrsx,
    relid      LIKE vrsx-relid,
    objsubtype LIKE vrsx-objsubtype,
    objname    LIKE vrsx-objname,
    versno     LIKE vrsx-versno,
  END OF fs_vrsx.

DATA:
  t_vrsx LIKE
     TABLE OF
           fs_vrsx WITH HEADER LINE.

START-OF-SELECTION.
  SELECT relid
         objsubtype
         objname
         versno
    FROM vrsx
    INTO TABLE t_vrsx
    UP TO 5 ROWS.

  LOOP AT t_vrsx.
    CONCATENATE t_vrsx-relid
                t_vrsx-objsubtype
                t_vrsx-objname
                t_vrsx-versno
                       INTO d_xtab SEPARATED BY ','.
    APPEND d_xtab TO d_itab.
  ENDLOOP.

  DATA: v_usr_action TYPE i,
        v_path       TYPE string,
        v_fullpath   TYPE string,
        v_filename   TYPE string.

  CLEAR: v_usr_action,
         v_path,
         v_fullpath,
         v_filename.

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      window_title         = 'Please select the location'
      default_extension    = 'TXT'
      default_file_name    = 'file'
      file_filter          = '*.txt'
    CHANGING
      filename             = v_filename
      path                 = v_path
      fullpath             = v_fullpath
      user_action          = v_usr_action
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

* Check if the user clicked OK
  IF v_usr_action <> 0.
    EXIT.
  ENDIF.

* Do the actual download
  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename             = v_filename
    CHANGING
      data_tab             = d_itab[]
    EXCEPTIONS
      file_not_found       = 1
      file_write_error     = 2
      filesize_not_allowed = 3
      invalid_type         = 5
      no_batch             = 6
      unknown_error        = 7
      OTHERS               = 8.
