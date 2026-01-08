@EndUserText.label: 'ZRAP_A_FILE_PARAMETER'
define root abstract entity ZRAP_A_FILE_PARAMETER 
{
  // Dummy is a dummy field
  @UI.hidden: true
  dummy : abap_boolean;
  _FileData : association [1] to ZRAP_A_FILE_DATA on 1 = 1;
}
