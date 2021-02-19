*&---------------------------------------------------------------------*
*& Report ZDEMO_EXPORT_XLSX_WITH_PATH
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZDEMO_EXPORT_XLSX_WITH_PATH.

selection-screen begin of block b1 with frame .
  parameters : p_file type ibipparms-path obligatory.
selection-screen end of block b1 .

*--------------------------------------------------------------------*
* at selection screen
*--------------------------------------------------------------------*
at selection-screen on value-request for p_file.

  data : lv_filename type string,
         lv_path     type string,
         lv_fullpath type string.

  call method cl_gui_frontend_services=>file_save_dialog
    exporting
      window_title      = 'Enter File Name'
      default_extension = 'XLSX'
      default_file_name = 'Demo'
    changing
      filename          = lv_filename
      path              = lv_path
      fullpath          = lv_fullpath.

  p_file = lv_fullpath .

*--------------------------------------------------------------------*
* start of selection
*--------------------------------------------------------------------*
start-of-selection .

  data : lt_excel_structure      type table of t001,
         lr_excel_structure      type ref to data,
         lv_content              type xstring,
         ls_stream               type /iwbep/if_mgw_core_srv_runtime=>ty_s_media_resource,
         lo_table_row_descriptor type ref to cl_abap_structdescr,
         lo_source_table_descr   type ref to cl_abap_tabledescr,
         lv_filename             type bapidocid,
         ls_header               type ihttpnvp.

  select from t001 fields *
  into table @lt_excel_structure .

  "create data reference for internal table and RTTI class instance to query fields
  get reference of lt_excel_structure into lr_excel_structure.
  data(lo_itab_services) = cl_salv_itab_services=>create_for_table_ref( lr_excel_structure ).
  lo_source_table_descr ?= cl_abap_tabledescr=>describe_by_data_ref( lr_excel_structure  ).
  lo_table_row_descriptor ?= lo_source_table_descr->get_table_line_type( ).
  data(lt_fields) = lo_table_row_descriptor->get_ddic_field_list( p_langu = sy-langu  ) .

  "excel instantiate
  data(lo_tool_xls) = cl_salv_export_tool_ats_xls=>create_for_excel(
                            exporting r_data =  lr_excel_structure  ) .

  "Add columns to sheet
  data(lo_config) = lo_tool_xls->configuration( ).
  loop at lt_fields assigning field-symbol(<lfs_field>) .
    lo_config->add_column(
      exporting
        header_text          =  conv string( <lfs_field>-scrtext_l )
        field_name           =  conv string( <lfs_field>-fieldname )
        display_type         =   if_salv_bs_model_column=>uie_text_view ).
  endloop .

  "get excel in xstring
  lo_tool_xls->read_result(  importing content  = lv_content  ).

  "file download
  data : lt_binary_tab type table of sdokcntasc,
         lv_length     type i.

  call function 'SCMS_XSTRING_TO_BINARY'
    exporting
      buffer        = lv_content
    importing
      output_length = lv_length
    tables
      binary_tab    = lt_binary_tab.

  call function 'GUI_DOWNLOAD'
    exporting
      bin_filesize            = lv_length
      filename                = conv string( p_file )
      filetype                = 'BIN'
    tables
      data_tab                = lt_binary_tab
    exceptions
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
      others                  = 22.

  if sy-subrc <> 0.
* Implement suitable error handling here
  endif.