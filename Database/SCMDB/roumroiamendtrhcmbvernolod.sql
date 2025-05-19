

/********************************************************************************/
/* Procedure    :ROUMROIAmendTrHCMBVerNoLod                                     */
/* Description  :                                                               */
/********************************************************************************/
/* Customer     :MODEL                                                          */
/* Project      :MODEL                                                          */
/********************************************************************************/
/* Referenced   :                                                               */
/* Tables       :                                                               */
/********************************************************************************/
/* Development History                                                          */
/********************************************************************************/
/* Author       :RITSL                                                          */
/* Date         :2/19/2025 3:27:06 PM                                           */
/********************************************************************************/
/* Modification History                                                         */
/********************************************************************************/
/* Modified by  :                                                               */
/* Date         :                                                               */
/* Description  :                                                               */
/********************************************************************************/

Create    procedure roumroiamendtrhcmbvernolod                                        
	@ctxt_user                     Ctxt_User,
	@ctxt_service                  Ctxt_Service,
	@ctxt_role                     Ctxt_Role,
	@ctxt_ouinstance               Ctxt_OUInstance,
	@ctxt_language                 Ctxt_Language,
	@_analysiscode                 _varchar10,
	@_assetclass                   _varchar10,
	@_assetclassdescription        _varchar10,
	@_assetgroup                   _varchar10,
	@_assetgroupdesc               _varchar10,
	@_assetlocation                _varchar10,
	@_assetvalue                   _amount,
	@_cooling_period               _Int4,
	@_costcentre                   _varchar10,
	@_currency                     _varchar1,
	@_financebook                  _varchar10,
	@_guid                         _GUID,
	@_interestperannum             _amount,
	@_leaseagreementno             _varchar10,
	@_rentalamount                 _amount,
	@_rentalenddate                _date,
	@_rentalstartdate              _date,
	@_rouassetonsecuritydeposit    _amount,
	@_roucontractdate              _date,
	@_roudescription               _varchar10,
	@_rouincrclauseappl1           _varchar1,
	@_rouno                        _varchar10,
	@_securitydeposit              _amount,
	@_status                       status,
	@_subanalysiscode              _varchar10,
	@_suppliercode                 _varchar1,
	@_suppliername                 _varchar13,
	@_transactiondatehdr           _date,
	@_usageid                      _varchar10,
	@currency_hdn                  _varchar10,
	@fin_book_hdn                  _varchar10,
	@m_errorid                     int output

as
Begin

	Set nocount on

	Select @ctxt_user                     =ltrim(rtrim(@ctxt_user))
	Select @ctxt_service                  =ltrim(rtrim(@ctxt_service))
	Select @ctxt_role                     =ltrim(rtrim(@ctxt_role))
	Select @_analysiscode                 =ltrim(rtrim(@_analysiscode))
	Select @_assetclass                   =ltrim(rtrim(@_assetclass))
	Select @_assetclassdescription        =ltrim(rtrim(@_assetclassdescription))
	Select @_assetgroup                   =ltrim(rtrim(@_assetgroup))
	Select @_assetgroupdesc               =ltrim(rtrim(@_assetgroupdesc))
	Select @_assetlocation                =ltrim(rtrim(@_assetlocation))
	Select @_costcentre                   =ltrim(rtrim(@_costcentre))
	Select @_currency                     =ltrim(rtrim(@_currency))
	Select @_financebook                  =ltrim(rtrim(@_financebook))
	Select @_guid                         =ltrim(rtrim(@_guid))
	Select @_leaseagreementno             =ltrim(rtrim(@_leaseagreementno))
	Select @_roudescription               =ltrim(rtrim(@_roudescription))
	Select @_rouincrclauseappl1           =ltrim(rtrim(@_rouincrclauseappl1))
	Select @_rouno                        =ltrim(rtrim(@_rouno))
	Select @_status                       =ltrim(rtrim(@_status))
	Select @_subanalysiscode              =ltrim(rtrim(@_subanalysiscode))
	Select @_suppliercode                 =ltrim(rtrim(@_suppliercode))
	Select @_suppliername                 =ltrim(rtrim(@_suppliername))
	Select @_usageid                      =ltrim(rtrim(@_usageid))
	Select @currency_hdn                  =ltrim(rtrim(@currency_hdn))
	Select @fin_book_hdn                  =ltrim(rtrim(@fin_book_hdn))
	-- @m_errorid should be 0 to Indicate Success
	Set @m_errorid = 0


	--null checking
	If @ctxt_user='~#~'
		Select @ctxt_user=null
	If @ctxt_service='~#~'
		Select @ctxt_service=null
	If @ctxt_role='~#~'
		Select @ctxt_role=null
	If @ctxt_ouinstance=-915
		Select @ctxt_ouinstance=null
	If @ctxt_language=-915
		Select @ctxt_language=null
	If @_analysiscode='~#~'
		Select @_analysiscode=null
	If @_assetclass='~#~'
		Select @_assetclass=null
	If @_assetclassdescription='~#~'
		Select @_assetclassdescription=null
	If @_assetgroup='~#~'
		Select @_assetgroup=null
	If @_assetgroupdesc='~#~'
		Select @_assetgroupdesc=null
	If @_assetlocation='~#~'
		Select @_assetlocation=null
	If @_assetvalue=-915
		Select @_assetvalue=null
	If @_cooling_period=-915
		Select @_cooling_period=null
	If @_costcentre='~#~'
		Select @_costcentre=null
	If @_currency='~#~'
		Select @_currency=null
	If @_financebook='~#~'
		Select @_financebook=null
	If @_guid='~#~'
		Select @_guid=null
	If @_interestperannum=-915
		Select @_interestperannum=null
	If @_leaseagreementno='~#~'
		Select @_leaseagreementno=null
	If @_rentalamount=-915
		Select @_rentalamount=null
	If @_rentalenddate='1900-01-01'
		Select @_rentalenddate=null
	If @_rentalstartdate='1900-01-01'
		Select @_rentalstartdate=null
	If @_rouassetonsecuritydeposit=-915
		Select @_rouassetonsecuritydeposit=null
	If @_roucontractdate='1900-01-01'
		Select @_roucontractdate=null
	If @_roudescription='~#~'
		Select @_roudescription=null
	If @_rouincrclauseappl1='~#~'
		Select @_rouincrclauseappl1=null
	If @_rouno='~#~'
		Select @_rouno=null
	If @_securitydeposit=-915
		Select @_securitydeposit=null
	If @_status='~#~'
		Select @_status=null
	If @_subanalysiscode='~#~'
		Select @_subanalysiscode=null
	If @_suppliercode='~#~'
		Select @_suppliercode=null
	If @_suppliername='~#~'
		Select @_suppliername=null
	If @_transactiondatehdr='1900-01-01'
		Select @_transactiondatehdr=null
	If @_usageid='~#~'
		Select @_usageid=null
	If @currency_hdn='~#~'
		Select @currency_hdn=null
	If @fin_book_hdn='~#~'
		Select @fin_book_hdn=null

	--errors mapped


	Select	max(ROu_H_Version)	 '_versionno',
			max(ROu_H_Version)	 'version_hdn'
	From	Zrit_Maintain_ROU_Hdr	with	(nolock)
	Where	ROu_H_No	=	@_rouno
	And		ROu_H_Ou	=	@ctxt_ouinstance

	--output parameters
	/*
	Select  
		_versionno                    '_versionno',
		version_hdn                   'version_hdn'

	*/
	Set nocount off
End



