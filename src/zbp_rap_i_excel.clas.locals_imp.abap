*CLASS lsc_zrap_i_excel DEFINITION INHERITING FROM cl_abap_behavior_saver.
*
*  PROTECTED SECTION.
*
*    METHODS save_modified REDEFINITION.
*
*ENDCLASS.
*
*CLASS lsc_zrap_i_excel IMPLEMENTATION.
*
*  METHOD save_modified.
*    IF create-excel IS NOT INITIAL.
*      READ ENTITIES OF zrap_i_excel IN LOCAL MODE
*        ENTITY excel
*          ALL FIELDS
*          WITH CORRESPONDING #( create-excel )
*        RESULT DATA(lt_excel).
*    ENDIF.
*
*    RAISE ENTITY EVENT zrap_i_excel~refreshdata
*      FROM VALUE #( FOR ls_excel IN create-excel ( %key = ls_excel-%key ) ).
*  ENDMETHOD.
*
*ENDCLASS.

CLASS lhc_zrap_i_excel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_file,
             customer TYPE zrap_i_excel-customer,
             article  TYPE zrap_i_excel-article,
           END OF ty_file.
    TYPES: tt_file TYPE STANDARD TABLE OF ty_file WITH DEFAULT KEY.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR excel RESULT result.
    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE excel.
    METHODS fileupload FOR MODIFY
      IMPORTING keys FOR ACTION excel~fileupload.
    METHODS filedownload FOR MODIFY
      IMPORTING keys FOR ACTION excel~filedownload RESULT result.
    METHODS validatedata FOR VALIDATE ON SAVE
      IMPORTING keys FOR excel~validatedata.
    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR excel RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR excel RESULT result.
    METHODS call_bapi FOR MODIFY
      IMPORTING keys FOR ACTION excel~call_bapi RESULT result.
    METHODS checkmessage FOR DETERMINE ON MODIFY
      IMPORTING keys FOR excel~checkmessage.
ENDCLASS.

CLASS lhc_zrap_i_excel IMPLEMENTATION.

  METHOD get_global_features.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zrap_i_excel IN LOCAL MODE
      ENTITY excel
        ALL FIELDS
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_excel).

    result = VALUE #( FOR ls_excel IN lt_excel
                    ( %tky    = ls_excel-%tky
                      %update = COND #( WHEN ls_excel-Processed EQ abap_true
                                        THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                      %delete = COND #( WHEN ls_excel-Processed EQ abap_true
                                        THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ) ) ).

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD precheck_create.
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
        <ls_create>-%control    = VALUE #( customer = if_abap_behv=>mk-on
                                           article  = if_abap_behv=>mk-on ).
        <ls_create>-messagetype = 'E'.
        <ls_create>-messagecode = 1.
        <ls_create>-processed   = abap_false.
        <ls_create>-messagetext = |Data is already exist!{ <ls_create>-customer }/{ <ls_create>-article }|.
        APPEND VALUE #( %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = |Data is already exist!{ <ls_create>-customer }/{ <ls_create>-article }| ) )
          TO reported-excel.
      ELSE.
        <ls_create>-%control    = VALUE #( customer = if_abap_behv=>mk-on
                                           article  = if_abap_behv=>mk-on ).
        <ls_create>-processed   = abap_false.
        <ls_create>-messagetype = 'S'.
        <ls_create>-messagetext = |Data checked successfully!|.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zrap_i_excel IN LOCAL MODE
      ENTITY excel
        CREATE FIELDS ( customer article messagetype messagecode messagetext processed ) AUTO FILL CID
        WITH lt_create
        REPORTED DATA(lt_report)
        FAILED DATA(lt_failed)
        MAPPED mapped.
*    IF lt_failed IS INITIAL.
*      APPEND VALUE #( %msg = new_message_with_text( severity = if_abap_behv_message=>severity-warning
*                                                    text     = 'Please click "Go" to refreshing data after uploading!' ) )
*        TO reported-excel.
*    ENDIF.

*    result = VALUE #( FOR ls_mapped IN mapped-excel ( %cid = ls_mapped-%cid %param-%tky = ls_mapped-%tky ) ).

  ENDMETHOD.


  METHOD filedownload.

*    DATA(lo_write_access) = xco_cp_xlsx=>document->empty( )->write_access( ).
*    DATA(lo_worksheet) = lo_write_access->get_workbook( )->worksheet->at_position( 1 ).
*    lo_worksheet->set_name( 'test' ).
*    DATA(lo_selection) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
*                           )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
*                           )->to_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'B' )
*                           )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 1 )
*                           )->get_pattern( ).
*
*    DATA(lt_download) = VALUE tt_file( ( customer = 'Customer' article  = 'Article' ) ).
*
*    lo_worksheet->select( lo_selection )->row_stream( )->operation->write_from( REF #( lt_download )
*      )->execute( ).
*
*    DATA(lv_file_content) = lo_write_access->get_file_content( ).

    READ ENTITIES OF zrap_i_template
      ENTITY template
        ALL FIELDS WITH VALUE #( ( %key-progid = 'ZTEST' ) )
      RESULT DATA(lt_template).

    DATA(ls_template) = VALUE #( lt_template[ 1 ] OPTIONAL ).
    "data(lv_filcontent) = CL_WEB_HTTP_UTILITY=>encode_x_base64( ls_template-filecontent ).
    result = VALUE #( FOR key IN keys (
                        %cid   = key-%cid
                        %param = VALUE #( filecontent = ls_template-filecontent
                                          filename    = ls_template-filename
                                          mimetype    = ls_template-mimetype ) ) ).

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
        WHERE who_uuid NE @ls_excel-whouuid
          AND customer EQ @ls_excel-customer
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

  METHOD call_bapi.

    READ ENTITIES OF zrap_i_excel IN LOCAL MODE
      ENTITY excel
        FIELDS ( customer )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_excel).

    DELETE lt_excel WHERE %is_draft NE if_abap_behv=>mk-on.

    IF lt_excel IS INITIAL.
      MODIFY ENTITIES OF zrap_i_excel IN LOCAL MODE
        ENTITY excel
        UPDATE FIELDS ( processed messagetext )
        WITH VALUE #( FOR ls_key IN keys ( %tky        = ls_key-%tky
                                           processed   = abap_true
                                           messagetext = |Data processed successfully!| ) )
        REPORTED reported
        FAILED failed
        MAPPED mapped.
    ELSE.
      failed-excel = VALUE #( FOR ls_excel IN lt_excel ( %tky = ls_excel-%tky ) ).
      reported-excel = VALUE #(  FOR ls_excel IN lt_excel ( %tky = ls_excel-%tky
                        %state_area         = if_abap_behv=>state_area_all
                        %msg                = new_message_with_text(
                                                text     = |Data is draft!Please save first|
                                                severity = if_abap_behv_message=>severity-error )
                        %element-customer   = if_abap_behv=>mk-on
                        %element-article    = if_abap_behv=>mk-on ) ).
    ENDIF.

  ENDMETHOD.

  METHOD checkmessage.
    READ ENTITIES OF zrap_i_excel IN LOCAL MODE
      ENTITY excel
        FIELDS ( customer )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_excel).

    LOOP AT lt_excel INTO DATA(ls_excel).
      SELECT COUNT( * )
        FROM zrap_excel
        WHERE who_uuid NE @ls_excel-whouuid
          AND customer EQ @ls_excel-customer
          AND article  EQ @ls_excel-article.
      IF sy-subrc NE 0.
        MODIFY ENTITIES OF zrap_i_excel IN LOCAL MODE
          ENTITY excel
          UPDATE FIELDS ( messagetype messageCode messagetext )
          WITH VALUE #( ( %tky        = ls_excel-%tky
                          messagetype = 'S'
                          messageCode = 3
                          messagetext = |Data checked successfully!| ) ).
      ELSE.
        MODIFY ENTITIES OF zrap_i_excel IN LOCAL MODE
          ENTITY excel
          UPDATE FIELDS ( messagetype messageCode messagetext )
          WITH VALUE #( ( %tky        = ls_excel-%tky
                          messagetype = 'E'
                          messageCode = 1
                          messagetext = |Data is already exist! { ls_excel-customer }/{ ls_excel-article }| ) )
          REPORTED DATA(lt_reported).

        reported-excel = CORRESPONDING #( lt_reported-excel ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
