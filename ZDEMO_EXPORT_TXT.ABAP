*&---------------------------------------------------------------------*
*& Report ZDEMO_EXPORT_TXT
*&---------------------------------------------------------------------*
*& DESCRIPTION: Export text file to local file
*&---------------------------------------------------------------------*
REPORT zdemo_export_txt.

DATA: h_xtab TYPE string.

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
  BEGIN OF fs_head,
    relid(5)       TYPE c,
    objsubtype(10) TYPE c,
    objname(6)     TYPE c,
    versno(6)      TYPE c,
  END OF fs_head.

DATA:
  t_head LIKE
   TABLE OF
         fs_head WITH HEADER LINE.

DATA:
  t_vrsx LIKE
     TABLE OF
           fs_vrsx WITH HEADER LINE.

DATA: vrsx_lines TYPE i,
      gd_percent TYPE i.

fs_head-relid = 'RELID'.
fs_head-objsubtype = 'OBJSUBTYPE'.
fs_head-objname = 'OBJNAME'.
fs_head-versno  = 'VERSNO'.
APPEND fs_head TO t_head.

*SELECT-OPTIONS: mats FOR mara-matnr OBLIGATORY.
SELECT-OPTIONS:
  s_versno FOR fs_vrsx-versno.
PARAMETERS: p_relid LIKE vrsx-relid.

INITIALIZATION.
  s_versno-low = '1'.
  s_versno-high = '2'.
  APPEND s_versno.

*AT SELECTION-SCREEN. .
*  IF s_versno-low = ' '.
*    MESSAGE i000(zkmessage).
*  ELSEIF s_versno-high = ' '.
*    MESSAGE i001(zkmessage).
*  ENDIF.

START-OF-SELECTION.
  SELECT relid
         objsubtype
         objname
         versno
    FROM vrsx
    INTO TABLE t_vrsx
*    UP TO 10000 ROWS
   WHERE versno IN s_versno.

*  CHECK sy-subrc EQ 0.
*  vrsx_lines = sy-dbcnt.
*  CLEAR: gd_percent.

  IF NOT t_vrsx[] IS INITIAL.
    vrsx_lines = sy-dbcnt.
    CLEAR: gd_percent.

    LOOP AT t_head.
      CONCATENATE t_head-relid
                  t_head-objsubtype
                  t_head-objname
                  t_head-versno
                         INTO h_xtab SEPARATED BY ','.
      APPEND h_xtab TO d_itab.
    ENDLOOP.

    LOOP AT t_vrsx.
      CONCATENATE t_vrsx-relid
                  t_vrsx-objsubtype
                  t_vrsx-objname
                  t_vrsx-versno
                         INTO d_xtab SEPARATED BY ','.
      APPEND d_xtab TO d_itab.

      PERFORM progress_bar USING 'Retrieving data...'(001)
                               sy-tabix
                               vrsx_lines.
*     WAIT UP TO 2 SECONDS.
    ENDLOOP.

    CALL FUNCTION 'TH_REDISPATCH'
      EXPORTING
        check_runtime = 0.

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
        default_file_name    = 'vrsx'
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

    IF v_usr_action <> 0.
      EXIT.
    ENDIF.

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

    IF sy-subrc EQ 0.
      MESSAGE 'Download successful' TYPE 'I'.
    ENDIF.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    MESSAGE 'No data found' TYPE 'I'.
  ENDIF.

FORM progress_bar USING    p_value
                           p_tabix
                           p_nlines.
  DATA: w_text(40),
        w_percentage      TYPE p,
        w_percent_char(3).

  w_percentage = ( p_tabix / p_nlines ) * 100.
  w_percent_char = w_percentage.
  SHIFT w_percent_char LEFT DELETING LEADING ' '.
  CONCATENATE p_value w_percent_char '% Complete'(002) INTO w_text.

  IF w_percentage GT gd_percent OR p_tabix EQ 1.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = w_percentage
        text       = w_text.
    gd_percent = w_percentage.
  ENDIF.
ENDFORM.
