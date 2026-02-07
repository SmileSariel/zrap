CLASS zcl_prog_query DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_prog_query IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    update zrap_excel
      set processed = @abap_false
      where processed ne @abap_false.

    update zrap_excel_d
      set processed = @abap_false
      where processed ne @abap_false.

    commit work and wait.
  ENDMETHOD.
ENDCLASS.
