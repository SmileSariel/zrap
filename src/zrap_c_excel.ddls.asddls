@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZRAP_EXCEL'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZRAP_C_EXCEL
  provider contract TRANSACTIONAL_QUERY
  as projection on ZRAP_I_EXCEL
  association [1..1] to ZRAP_I_EXCEL as _BaseEntity on $projection.WHOUUID = _BaseEntity.WHOUUID
{
  key WhoUUID,
  Customer,
  Article,
  @Semantics: {
    User.Createdby: true
  }
  Createdby,
  @Semantics: {
    Systemdatetime.Createdat: true
  }
  Createdat,
  @Semantics: {
    User.Localinstancelastchangedby: true
  }
  Lastchangedby,
  @Semantics: {
    Systemdatetime.Localinstancelastchangedat: true
  }
  Lastchangedat,
  @Semantics: {
    Systemdatetime.Localinstancelastchangedat: true
  }
  Locallastchangedat,
  _BaseEntity
}
