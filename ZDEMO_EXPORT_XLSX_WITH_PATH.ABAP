*&---------------------------------------------------------------------*
*& Report ZDEMO_EXPORT_XLSX_WITH_PATH
*&---------------------------------------------------------------------*
*& DESCRIPTION: Export xlsx file with specific path
*&---------------------------------------------------------------------*
REPORT zdemo_export_xlsx_with_path.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME .
PARAMETERS : p_file TYPE ibipparms-path OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1 .

*--------------------------------------------------------------------*
* at selection screen
*--------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  DATA : lv_filename TYPE string,
         lv_path     TYPE string,
         lv_fullpath TYPE string.

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      window_title      = 'Enter File Name'
      default_extension = 'XLSX'
      default_file_name = 'Demo'
    CHANGING
      filename          = lv_filename
      path              = lv_path
      fullpath          = lv_fullpath.

  p_file = lv_fullpath .

*--------------------------------------------------------------------*
* start of selection
*--------------------------------------------------------------------*
START-OF-SELECTION .

  DATA : lt_excel_structure      TYPE TABLE OF t001,
         lr_excel_structure      TYPE REF TO data,
         lv_content              TYPE xstring,
         ls_stream               TYPE /iwbep/if_mgw_core_srv_runtime=>ty_s_media_resource,
         lo_table_row_descriptor TYPE REF TO cl_abap_structdescr,
         lo_source_table_descr   TYPE REF TO cl_abap_tabledescr,
         lv_filename             TYPE bapidocid,
         ls_header               TYPE ihttpnvp.

  SELECT FROM t001 FIELDS *
  INTO TABLE @lt_excel_structure
  UP TO 100 ROWS.

  "create data reference for internal table and RTTI class instance to query fields
  GET REFERENCE OF lt_excel_structure INTO lr_excel_structure.
  DATA(lo_itab_services) = cl_salv_itab_services=>create_for_table_ref( lr_excel_structure ).
  lo_source_table_descr ?= cl_abap_tabledescr=>describe_by_data_ref( lr_excel_structure  ).
  lo_table_row_descriptor ?= lo_source_table_descr->get_table_line_type( ).
  DATA(lt_fields) = lo_table_row_descriptor->get_ddic_field_list( p_langu = sy-langu  ) .

  "excel instantiate
  DATA(lo_tool_xls) = cl_salv_export_tool_ats_xls=>create_for_excel(
                            EXPORTING r_data =  lr_excel_structure  ) .

  "Add columns to sheet
  DATA(lo_config) = lo_tool_xls->configuration( ).
  LOOP AT lt_fields ASSIGNING FIELD-SYMBOL(<lfs_field>) .
    lo_config->add_column(
      EXPORTING
        header_text          =  CONV string( <lfs_field>-scrtext_l )
        field_name           =  CONV string( <lfs_field>-fieldname )
        display_type         =   if_salv_bs_model_column=>uie_text_view ).
  ENDLOOP .

  "get excel in xstring
  lo_tool_xls->read_result(  IMPORTING content  = lv_content  ).

  "file download
  DATA : lt_binary_tab TYPE TABLE OF sdokcntasc,
         lv_length     TYPE i.

  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = lv_content
    IMPORTING
      output_length = lv_length
    TABLES
      binary_tab    = lt_binary_tab.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      bin_filesize            = lv_length
      filename                = CONV string( p_file )
      filetype                = 'BIN'
    TABLES
      data_tab                = lt_binary_tab
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

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.