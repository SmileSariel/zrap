@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZRAP_TEMPLATE'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZRAP_C_TEMPLATE
  provider contract transactional_query
  as projection on ZRAP_I_TEMPLATE
  association [1..1] to ZRAP_I_TEMPLATE as _BaseEntity on $projection.Progid = _BaseEntity.Progid
{
  key Progid,
  Comments,
  FileName,
  MimeType,  
  @Semantics.largeObject : { 
    mimeType: 'MimeType', 
    fileName: 'FileName', 
    acceptableMimeTypes: [ 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ],
    cacheControl.maxAge: #MEDIUM,
    contentDispositionPreference: #INLINE //#ATTACHMENT - download as file #INLINE - open in new window
  }  
  @EndUserText.label: 'Template'
  FileContent,
  @EndUserText.label: 'Instructions'
  Instruction,
  @Semantics: {
    user.createdBy: true
  }
  LocalCreatedBy,
  @Semantics: {
    systemDateTime.createdAt: true
  }
  LocalCreatedAt,
  @Semantics: {
    user.localInstanceLastChangedBy: true
  }
  LocalLastChangedBy,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  LocalLastChangedAt,
  @Semantics: {
    systemDateTime.lastChangedAt: true
  }
  LastChangedAt,
  
  _BaseEntity
}
