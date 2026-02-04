@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZRAP_EXCEL'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZRAP_C_EXCEL
  provider contract transactional_query
  as projection on ZRAP_I_EXCEL
  association [1..1] to ZRAP_I_EXCEL as _BaseEntity on $projection.WhoUUID = _BaseEntity.WhoUUID
{
  key WhoUUID,
  Customer,
  Article,
  MessageType,
  MessageCode,
  MessageText,
  Processed,
  @Semantics: {
    user.createdBy: true
  }
  Createdby,
  @Semantics: {
    systemDateTime.createdAt: true
  }
  Createdat,
  @Semantics: {
    user.localInstanceLastChangedBy: true
  }
  Lastchangedby,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  Lastchangedat,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  Locallastchangedat,
  _BaseEntity
}
