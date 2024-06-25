*&---------------------------------------------------------------------*
*& Report ZDEMO_EXPORT_XLS
*&---------------------------------------------------------------------*
*& DESCRIPTION: Export xls file to local file
*&---------------------------------------------------------------------*
REPORT zdemo_export_xls.

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

*DATA:
*  BEGIN OF fs_vrsx,
*    relid(100)      TYPE c,
*    objsubtype(100) TYPE c,
*    objname(100)    TYPE c,
*    versno(100)     TYPE c,
*  END OF fs_vrsx.

*DATA:
*  BEGIN OF fs_head,
*    relid(5)       TYPE c,
*    objsubtype(10) TYPE c,
*    objname(6)     TYPE c,
*    versno(6)      TYPE c,
*  END OF fs_head.
*
*DATA:
*  t_head LIKE
*   TABLE OF
*         fs_head WITH HEADER LINE.

DATA : BEGIN OF it_heading OCCURS 0,
         text(15),
       END OF it_heading.

it_heading-text = 'RELID'.
APPEND it_heading.
it_heading-text = 'OBJSUBTYPE'.
APPEND it_heading.
it_heading-text = 'OBJNAME'.
APPEND it_heading.
it_heading-text = 'VERSNO'.
APPEND it_heading.

DATA:
  t_vrsx LIKE
     TABLE OF
           fs_vrsx WITH HEADER LINE.

DATA: vrsx_lines TYPE i,
      gd_percent TYPE i.

*SELECT-OPTIONS: mats FOR mara-matnr OBLIGATORY.
SELECT-OPTIONS:
  s_versno FOR fs_vrsx-versno.
PARAMETERS: p_relid LIKE vrsx-relid DEFAULT 'CU' OBLIGATORY.

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
   WHERE versno IN s_versno
    AND relid EQ p_relid.
  vrsx_lines = sy-dbcnt.
  CLEAR: gd_percent.
  PERFORM progress_bar USING 'Retrieving data...'(001)
                                 sy-tabix
                                 vrsx_lines.

  CALL FUNCTION 'TH_REDISPATCH'
    EXPORTING
      check_runtime = 0.

  IF NOT t_vrsx[] IS INITIAL.

*    fs_head-relid = 'RELID'.
*    fs_head-objsubtype = 'OBJSUBTYPE'.
*    fs_head-objname = 'OBJNAME'.
*    fs_head-versno  = 'VERSNO'.
*    INSERT fs_head INTO t_vrsx INDEX 1.

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
        default_extension    = 'XLS'
        default_file_name    = 'vrsx'
        file_filter          = '*.xls'
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

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                = v_filename
        filetype                = 'ASC'
*       filetype                = 'DAT'
        write_field_separator   = 'X'
*       append                  = 'X'
*       header                  = '00'
      TABLES
        data_tab                = t_vrsx
        fieldnames              = it_heading[]
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        OTHERS                  = 22.

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
