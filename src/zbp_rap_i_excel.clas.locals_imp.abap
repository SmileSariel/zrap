CLASS lhc_zrap_i_excel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_file,
             customer TYPE zrap_i_excel-customer,
             article  TYPE zrap_i_excel-article,
           END OF ty_file.
    TYPES: tt_file TYPE STANDARD TABLE OF ty_file WITH DEFAULT KEY.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR excel RESULT result.

    METHODS fileupload FOR MODIFY
      IMPORTING keys FOR ACTION excel~fileupload.
    METHODS filedownload FOR MODIFY
      IMPORTING keys FOR ACTION excel~filedownload RESULT result.
    METHODS validatedata FOR VALIDATE ON SAVE
      IMPORTING keys FOR excel~validatedata.
    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE excel.
ENDCLASS.

CLASS lhc_zrap_i_excel IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD fileupload.

    DATA lt_upload TYPE STANDARD TABLE OF ty_file.
    DATA lt_create TYPE TABLE FOR CREATE zrap_i_excel.

    DATA(ls_key) = VALUE #( keys[ 1 ] OPTIONAL ).

    DATA(lv_file_content) = ls_key-%param-_filedata-filecontent.
    DATA(LO_document) = xco_cp_xlsx=>document->for_file_content( lv_file_content )->read_access( ).
    DATA(lo_worksheet) = LO_document->get_workbook( )->worksheet->for_name( 'Sheet1' ).
    DATA(lo_selection) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
                           )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
                           )->to_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'B' )
                           )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 2 )
                           )->get_pattern( ).

    lo_worksheet->select( lo_selection )->row_stream( )->operation->write_to( REF #( lt_upload )
      )->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
      )->if_xco_xlsx_ra_operation~execute( ).

    lt_create = CORRESPONDING #( lt_upload ).

    LOOP AT lt_create ASSIGNING FIELD-SYMBOL(<ls_create>).

      SELECT COUNT( * )
        FROM zrap_excel
        WHERE customer EQ @<ls_create>-customer
          AND article  EQ @<ls_create>-article.
      IF sy-subrc EQ 0.
        <ls_create>-%is_draft   = if_abap_behv=>mk-on.
        <ls_create>-messagetype = 'E'.
        <ls_create>-messagecode = 1.
        <ls_create>-messagetext = |Data is already exist!{ <ls_create>-customer }/{ <ls_create>-article }|.
        APPEND VALUE #( %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = |Data is already exist!{ <ls_create>-customer }/{ <ls_create>-article }| ) )
          TO reported-excel.
      ELSE.
        <ls_create>-messagetype = 'S'.
        <ls_create>-messagetext = |Data saved successfully!|.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zrap_i_excel IN LOCAL MODE
      ENTITY excel
        CREATE FIELDS ( customer article messagetype messagecode messagetext ) AUTO FILL CID
        WITH lt_create
        REPORTED DATA(lt_report)
        FAILED DATA(lt_failed).
    IF lt_failed IS INITIAL.
      APPEND VALUE #( %msg = new_message_with_text( severity = if_abap_behv_message=>severity-warning
                                                    text     = 'Please click "Go" to refreshing data after uploading!' ) )
        TO reported-excel.
    ENDIF.

  ENDMETHOD.


  METHOD filedownload.

    DATA(lo_write_access) = xco_cp_xlsx=>document->empty( )->write_access( ).
    DATA(lo_worksheet) = lo_write_access->get_workbook( )->worksheet->at_position( 1 ).
    lo_worksheet->set_name( 'test' ).
    DATA(lo_selection) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
                           )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
                           )->to_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'B' )
                           )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 1 )
                           )->get_pattern( ).

    DATA(lt_download) = VALUE tt_file( ( customer = 'Customer' article  = 'Article' ) ).

    lo_worksheet->select( lo_selection )->row_stream( )->operation->write_from( REF #( lt_download )
      )->execute( ).

    DATA(lv_file_content) = lo_write_access->get_file_content( ).

    result = VALUE #( FOR key IN keys (
                        %cid    = key-%cid
                        %param  = VALUE #( filecontent = lv_file_content
                                           filename    = 'Download_Template.xlsx'
                                           mimetype    = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ) ) ).

    APPEND VALUE #( %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                  text     = 'Template has been downloaded!' ) )
      TO reported-excel.

  ENDMETHOD.

  METHOD validatedata.

    READ ENTITIES OF zrap_i_excel IN LOCAL MODE
      ENTITY excel
        FIELDS ( customer )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_excel).

    LOOP AT lt_excel INTO DATA(ls_excel).
      SELECT COUNT( * )
        FROM zrap_excel
        WHERE customer EQ @ls_excel-customer
          AND article  EQ @ls_excel-article.
      IF sy-subrc EQ 0.
        APPEND VALUE #( %tky = ls_excel-%tky ) TO failed-excel.

        APPEND VALUE #( %tky = ls_excel-%tky
                        %state_area         = if_abap_behv=>state_area_all
                        %msg                = new_message_with_text(
                                                text     = |Data is already exist!{ ls_excel-customer }/{ ls_excel-article }|
                                                severity = if_abap_behv_message=>severity-error )
                        %element-customer   = if_abap_behv=>mk-on
                        %element-article    = if_abap_behv=>mk-on ) TO reported-excel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD precheck_create.
  ENDMETHOD.
ENDCLASS.
