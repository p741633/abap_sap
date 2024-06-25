*&---------------------------------------------------------------------*
*& Report ZDEMO_CREATE_TXT_HEADER
*&---------------------------------------------------------------------*
*& DESCRIPTION: Create file on the local system with header (gui_download)
*&---------------------------------------------------------------------*
REPORT zdemo_create_txt_header.

DATA: h_itab TYPE TABLE OF string.
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
    relid(10)      TYPE c,
    objsubtype(10) TYPE c,
    objname(10)    TYPE c,
    versno(10)     TYPE c,
  END OF fs_head.

DATA:
  t_head LIKE
   TABLE OF
         fs_head WITH HEADER LINE.

DATA:
  t_vrsx LIKE
     TABLE OF
           fs_vrsx WITH HEADER LINE.

fs_head-relid = 'RELID'.
fs_head-objsubtype = 'OBJSUBTYPE'.
fs_head-objname = 'OBJNAME'.
fs_head-versno  = 'VERSNO'.
APPEND fs_head TO t_head.

SELECT-OPTIONS:
  s_versno FOR fs_vrsx-versno.

START-OF-SELECTION.
  SELECT relid
         objsubtype
         objname
         versno
    FROM vrsx
    INTO TABLE t_vrsx
    UP TO 5 ROWS
   WHERE versno IN s_versno.

  LOOP AT t_head.
    CONCATENATE t_head-relid
                t_head-objsubtype
                t_head-objname
                t_head-versno
                       INTO h_xtab SEPARATED BY ','.
    APPEND h_xtab TO h_itab.
  ENDLOOP.

  LOOP AT t_vrsx.
    CONCATENATE t_vrsx-relid
                t_vrsx-objsubtype
                t_vrsx-objname
                t_vrsx-versno
                       INTO d_xtab SEPARATED BY ','.
    APPEND d_xtab TO d_itab.
  ENDLOOP.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
*     BIN_FILESIZE            =
      filename                = 'D:\vrsx.txt'
      filetype                = 'ASC'
*     APPEND                  = ' '
      write_field_separator   = 'X'
*     HEADER                  = '00'
*     TRUNC_TRAILING_BLANKS   = ' '
*     WRITE_LF                = 'X'
*     COL_SELECT              = ' '
*     COL_SELECT_MASK         = ' '
*     DAT_MODE                = ' '
*     CONFIRM_OVERWRITE       = ' '
*     NO_AUTH_CHECK           = ' '
*     CODEPAGE                = ' '
*     IGNORE_CERR             = ABAP_TRUE
*     REPLACEMENT             = '#'
*     WRITE_BOM               = ' '
* IMPORTING
*     FILELENGTH              =
    TABLES
      data_tab                = h_itab
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
  IF sy-subrc NE 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = 'D:\vrsx.txt'
      filetype                = 'ASC'
      append                  = 'X'
      write_field_separator   = 'X'
    TABLES
      data_tab                = d_itab
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
*  MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
