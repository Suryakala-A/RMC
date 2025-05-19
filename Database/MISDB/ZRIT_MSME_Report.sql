----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- USe MISDB_TRG  
-- Exec ZRIT_MSME_Report 'Kil','CEMENT','201','','2021-01-01','2023-03-31','Ramcouser'  
--Exec ZRIT_MSME_Report 'PJLRMC','','','','','','','2024-01-01','2025-01-20','reportuser'  

/*  
Modification History :  
Amirtha P  RKILU-140  03.05.2023  
Nandhakumar B  RKILU-483  30.06.2023  
 /* Amirtha P.		20.01.2025		PJLMIS_COMP_02           */
*/  
/*M. HELAN          APRIL 21 2025      RPJRB-527   */
/*Suryakala A    17-05-2025    RPJRB-859*/
/*
exec ZRIT_MSME_Report @company_id=N'%',@bu_id=N'%',@zone=N'%',@branch=N'%',@nat_bus=N'%',@ou_id=N'%',@supplier_code=N'',@todate='2025-04-23 00:00:00',@userid=N'reportuser'
*/
  
CREATE    or alter     proc ZRIT_MSME_Report
@company_id  varchar(50),          
@bu_id varchar(50),
@zone varchar(50),
@branch varchar(40),
@nat_bus varchar(40),
@ou_id varchar(50),          
@supplier_code varchar(50),  

--@fromdate datetime,--varchar(10),--Datetime,/*Code commented by M. Helan on April 21 2025  RPJRB-527 */      --code modified by Nandhakumar B on 24 Apr 2023 for RKILU-140  --code modified for RKILU-483  
@todate datetime,--varchar(10),--Datetime,        --code modified by Nandhakumar B on 24 Apr 2023 for RKILU-140  --code modified for RKILU-483  
@userid varchar(20)     
as        
Begin        
set nocount on   

 /*Code Added for PJLMIS_COMP_02 Begins*/
 if @company_id = 'All' or isnull(@company_id,'')='' or @company_id = Null
	Select @company_id = '%'

 /*Code Added for PJLMIS_COMP_02 Ends*/
  
  --code added by Nandhakumar B on 24 Apr 2023 for RKILU-140 begins  
 -- select  @fromdate = cast(@fromdate as date)  /*Code commented by M. Helan on April 21 2025  RPJRB-527 */ 
  select  @todate = cast(@todate as date)  
  --code added by Nandhakumar B on 24 Apr 2023 for RKILU-140 ends  
  
    IF @ou_id in ('0','All','%')  
     begin  
                 Select  @ou_id =NULL     
     End 
	IF @bu_id in ('0','All','%')  
     begin  

         Select  @bu_id =NULL     
     End 
	 	     IF @zone in ('0','All','%')  
     begin  
                 Select  @zone =NULL     
     End 
	 	 	     IF @branch in ('0','All','%')  
     begin  
                 Select  @branch =NULL     
     End 
	 	 	 	     IF @nat_bus in ('0','All','%')  
     begin  
                 Select  @nat_bus =NULL     
     End 

     if @supplier_code in ('','All')  
     BEgin  
     select @supplier_code = null  
     End 
	 
	/*Code Added for PJLMIS_COMP_02 Begins*/

	if	@userid = 'reportuser' 
	begin 
		select @userid = 'superuser' 
	end

	Drop table if exists #user_ou

	Create Table #user_ou (ou int)

	Insert into #user_ou
	Select	distinct OUInstId
	From	DEPDB..fw_admin_OUInst_User  with (nolock)
	where	UserName	=	@userid 
	And		OUInstId IN (Select distinct OU_id FROM SCMDB..Zrit_Map_Zone_Branch_Nature_dtl WITH (NOLOCK)
	WHERE Bu_id	like isnull(@bu_id,Bu_id)
	And	Company_code like @company_id
	AND Zone	LIKE	isnull(@ZONE,Zone)
	AND Branch	LIKE	isnull(@BRANCH,Branch)
	AND	Nature_of_business like isnull(@nat_bus,Nature_of_business)
	And	OU_id	like	isnull(OU_id,@ou_id))

	/*Code Added for PJLMIS_COMP_02 Ends*/
  
Drop Table if Exists #Temp  
select Distinct 
	CONVERT(NVARCHAR(100),NULL) 'Company',
	CONVERT(NVARCHAR(200),NULL) 'Bu',
	CONVERT(NVARCHAR(200),NULL) 'Zone',
	CONVERT(NVARCHAR(200),NULL) 'Branch',
	CONVERT(NVARCHAR(200),NULL) 'Nat_bus',
	CONVERT(NVARCHAR(200),NULL) 'Plant_Name',
	CONVERT(NVARCHAR(200),doc.tran_ou)  'OU_Name',
	doc.supplier_code,  
    supp_spmn_supname,  
    supp_msme_type,   
    supp_msme_regno,  
    doc.fb_id,  
    doc.tran_no,  
    convert(varchar(11),doc.tran_date,105) as 'Tran Date',    
    CONVERT(NUMERIC(15,2),doc.tran_amount) as tran_amount,  
    doc.paid_status,   
 CONVERT(NUMERIC(15,2),doc.paid_amount)  paid_amount,    
    CONVERT(NUMERIC(15,2),doc.adjusted_amount) adjusted_amount,   
    CONVERT(NUMERIC(15,2),(isnull(doc.tran_amount,0.00) - isnull(doc.paid_amount,0.00) - isnull(doc.adjusted_amount,0.00))) as 'Balance Amount',  
    CONVERT(NUMERIC(15,2),doc.requested_amount) requested_amount,   
    doc.supp_inv_no,   
    convert(varchar(100),doc.supp_invoice_date,105) as 'Supplier Inv. Date',   
    Convert(varchar(100),doc.component_id) as component_id,  
    convert(Varchar(100),isnull(anchor_date,cdn.tran_date),105) as 'Anchor Date',   
    'CRE45' as 'Payterm',   
    convert(varchar(100),isnull(anchor_date,cdn.tran_date) + 45,105) as 'Due Date',  
    convert(varchar(5),isnull((DATEDIFF(Day, Getdate(), (isnull(anchor_date,cdn.tran_date) + 45))),0))  'OverDue Days'   
    --Code Added for RKILU-140 Begins  
    ,doc.tran_currency   
    ,convert (varchar(120) , null) 'paymentvoucher'  
    ,convert (numeric(28,2) , null) 'paymentvoucheramount'  
    ,convert (varchar(120) , null) 'paymentvoucherdate'  
    --Code Added for RKILU-140 Ends  
    into #Temp  
from scmdb..si_doc_hdr doc(nolock)  
inner join scmdb.dbo.Supp_Spmn_SuplMain (NoLock)   
on supplier_code = supp_spmn_supcode  
inner join  scmdb..scdn_dcnote_hdr cdn(nolock)  
on cdn.tran_no = doc.tran_no  
  and  cdn.tran_ou=doc.tran_ou/*code added by suryakala against RPJRB-859 on 15-05-2025(duplication issue) starts*/
 and cdn.tran_type=doc.tran_type
 and cdn.fb_id=doc.fb_id/*code added by suryakala against RPJRB-859 on 15-05-2025(duplication issue) ends*/
where paid_status in ('ppad','aut','req'/*,'PAD'*/) -- 'PAD'Added for RKILU-140  
/*Code commented and added by M. Helan on April 21 2025  RPJRB-527 */ 
--and doc.tran_date between isnull(@fromdate,doc.tran_date) and isnull(@todate,doc.tran_date)  
and cast(doc.tran_date as date) <= isnull(@todate,doc.tran_date)  
/*Code commented and added by M. Helan on April 21 2025  RPJRB-527 */ 


and supplier_code in (select distinct supp_spmn_supcode                   
        From Scmdb.dbo.Supp_Spmn_SuplMain (NoLock)                     
        Where isnull(supp_msme_type,'') <> ''   
          and supp_spmn_supcode =isnull(@supplier_code,supp_spmn_supcode) )   
and doc.tran_type in ('PM_EV','PM_MI','PM_PI','PM_SCA')   
and doc.doc_status <> 'RVD'  
and doc.tran_ou --= isnull(@ou_id, doc.tran_ou)
/*Code commented and Added for PJLMIS_COMP_02 Begins */
/*
IN (SELECT DISTINCT OU_id FROM SCMDB..Zrit_Map_Zone_Branch_Nature_dtl WITH (NOLOCK)
WHERE Bu_id	    =isnull(@bu_id,Bu_id)
AND Zone	=isnull(@zone,Zone)
AND Branch  =isnull(@branch,Branch)
AND OU_id   =isnull(@ou_id,OU_id)
and Nature_of_business =isnull(@nat_bus,Nature_of_business))
*/
in( Select ou from #user_ou with (nolock) )
/*Code commented and Added for PJLMIS_COMP_02 Ends */

and supp_spmn_supcode =isnull(@supplier_code,supp_spmn_supcode)   

union  
select Distinct 
CONVERT(NVARCHAR(100),NULL) 'Company',
	CONVERT(NVARCHAR(200),NULL) 'Bu',
	CONVERT(NVARCHAR(200),NULL) 'Zone',
	CONVERT(NVARCHAR(200),NULL) 'Branch',
	CONVERT(NVARCHAR(200),NULL) 'Nat_bus',
	CONVERT(NVARCHAR(200),NULL) 'Plant_Name',
	CONVERT(NVARCHAR(200),doc.tran_ou) 'OU_Name',
	doc.supplier_code,   
    supp_spmn_supname,  
    supp_msme_type,   
    supp_msme_regno,  
    doc.fb_id,  
    doc.tran_no,  
    convert(varchar(11),doc.tran_date,105) as 'Tran Date',   
    CONVERT(NUMERIC(15,2),doc.tran_amount) as tran_amount,  
    doc.paid_status,  
    CONVERT(NUMERIC(15,2),doc.paid_amount)  paid_amount ,   
    CONVERT(NUMERIC(15,2),doc.adjusted_amount) adjusted_amount,  
    CONVERT(NUMERIC(15,2),(Isnull(doc.tran_amount,0.00) - isnull(doc.paid_amount,0.00) - isnull(doc.adjusted_amount,0.00))) as 'Balance Amount', 
	CONVERT(NUMERIC(15,2),doc.requested_amount) requested_amount,  
    doc.supp_inv_no,  
    convert(varchar(100),doc.supp_invoice_date,105) as 'Supplier Inv. Date',    
    Convert(varchar(100),doc.component_id) as component_id,   
    convert(Varchar(100),isnull(anchor_date,cdn.tran_date),105) as 'Anchor Date',   
    'CRE45'as 'Payterm',  
     convert(varchar(100),isnull(anchor_date,cdn.tran_date) + 45,105) as 'Due Date',  
    --convert(varchar(100),isnull(anchor_date,cdn.tran_date),105)  as 'Due Date',  
    convert(varchar(5),isnull((DATEDIFF(Day, Getdate(), (isnull(anchor_date,cdn.tran_date) + 45))),0)) 'OverDue Days'  
    --Code Added for RKILU-140 Begins  
    ,doc.tran_currency   
    ,convert (varchar(120) , null) 'paymentvoucher'  
    ,convert (numeric(28,2) , null) 'paymentvoucheramount'  
    ,convert (varchar(120) , null) 'paymentvoucherdate'  
    --Code Added for RKILU-140 Ends  
from scmdb..si_doc_hdr doc(nolock)  
inner join scmdb.dbo.Supp_Spmn_SuplMain (NoLock)   
on supplier_code = supp_spmn_supcode  
Inner join  scmdb..sin_invoice_hdr cdn(nolock)  
on cdn.tran_no = doc.tran_no  
and  cdn.tran_ou=doc.tran_ou/*code added by suryakala against RPJRB-859 on 15-05-2025(duplication issue) starts*/
 and cdn.tran_type=doc.tran_type
 and cdn.fb_id=doc.fb_id/*code added by suryakala against RPJRB-859 on 15-05-2025(duplication issue) ends*/
where paid_status in ('ppad','aut','req'/*,'PAD'*/) -- 'PAD'Added for RKILU-140  
/*Code commented and added by M. Helan on April 21 2025  RPJRB-527 */ 
--and doc.tran_date between isnull(@fromdate,doc.tran_date) and isnull(@todate,doc.tran_date)  
and cast(doc.tran_date as date) <= isnull(@todate,doc.tran_date)  
/*Code commented and added by M. Helan on April 21 2025  RPJRB-527 */ 
and supplier_code in (select distinct supp_spmn_supcode                    
       From Scmdb.dbo.Supp_Spmn_SuplMain (NoLock)                     
       Where isnull(supp_msme_type,'') <> ''  
       and supp_spmn_supcode =isnull(@supplier_code,supp_spmn_supcode))   
and doc.tran_type in ('PM_EV','PM_MI','PM_PI','PM_SCA')  
and doc.doc_status <> 'RVD'   
and doc.tran_ou --= isnull(@ou_id, doc.tran_ou)  
/*Code commented and Added for PJLMIS_COMP_02 Begins */
/*
IN (SELECT DISTINCT OU_id FROM SCMDB..Zrit_Map_Zone_Branch_Nature_dtl WITH (NOLOCK)
WHERE Bu_id	    =isnull(@bu_id,Bu_id)
And	Company_code like @company_id 	/*Code Added for PJLMIS_COMP_02*/
AND Zone	=isnull(@zone,Zone)
AND Branch  =isnull(@branch,Bran

ch)
AND OU_id   =isnull(@ou_id,OU_id)
and Nature_of_business =isnull(@nat_bus,Nature_of_business))
*/
in( Select ou from #user_ou with (nolock) )
/*Code commented and Added for PJLMIS_COMP_02 Ends */

and supp_spmn_supcode =isnull(@supplier_code,supp_spmn_supcode)  
 
   
union  
  
select Distinct 
CONVERT(NVARCHAR(100),NULL) 'Company',
	CONVERT(NVARCHAR(200),NULL) 'Bu',
	CONVERT(NVARCHAR(200),NULL) 'Zone',
	CONVERT(NVARCHAR(200),NULL) 'Branch',
	CONVERT(NVARCHAR(200),NULL) 'Nat_bus',
	CONVERT(NVARCHAR(200),NULL) 'Plant_Name',
	CONVERT(NVARCHAR(200),doc.tran_ou) 'OU_Name',
	doc.supplier_code,  
    supp_spmn_supname,  
    supp_msme_type,  
    supp_msme_regno,  
    doc.fb_id,  
    doc.tran_no,   
    convert(varchar(11),doc.tran_date,105) as 'Tran Date',    
    CONVERT(NUMERIC(15,2),doc.tran_amount) as tran_amount,   
    doc.paid_status,   
	CONVERT(NUMERIC(15,2),doc.paid_amount)  paid_amount,   
    CONVERT(NUMERIC(15,2),doc.adjusted_amount) adjusted_amount,   
    CONVERT(NUMERIC(15,2),(isnull(doc.tran_amount,0.00) - isnull(doc.paid_amount,0.00) - isnull(doc.adjusted_amount,0.00))) as 'Balance Amount', 
	CONVERT(NUMERIC(15,2),doc.requested_amount) requested_amount,  
	doc.supp_inv_no,convert(varchar(100),doc.supp_invoice_date,105) as 'Supplier Inv. Date',    
    Convert(varchar(100),doc.component_id) as component_id,  
    convert(Varchar(100),isnull(anchor_date,cdn.tran_date),105) as 'Anchor Date',   
    'CRE45' as 'Payterm',  
    convert(varchar(100),isnull(anchor_date,cdn.tran_date) + 45,105) as 'Due Date',  
    convert(varchar(5),isnull((DATEDIFF(Day, Getdate(), (isnull(anchor_date,cdn.tran_date) + 45))),0))  'OverDue Days'  
    --Code Added for RKILU-140 Begins  
    ,doc.tran_currency   
    ,convert (varchar(120) , null) 'paymentvoucher'  
    ,convert (numeric(28,2) , null) 'paymentvoucheramount'  
    ,convert (varchar(120) , null) 'paymentvoucherdate'  
    --Code Added for RKILU-140 Ends  
 from scmdb..si_doc_hdr doc(nolock)  
 inner join scmdb.dbo.Supp_Spmn_SuplMain (NoLock)    
 on  supplier_code = supp_spmn_supcode  
 inner join scmdb..sdin_invoice_hdr cdn(nolock)  
 on cdn.tran_no = doc.tran_no   
 and cdn.tran_ou=doc.tran_ou/*code added by suryakala against RPJRB-859 on 15-05-2025(duplication issue) starts*/
 and cdn.tran_type=doc.tran_type
 and cdn.fb_id=doc.fb_id/*code added by suryakala against RPJRB-859 on 15-05-2025(duplication issue) ends*/
where paid_status in ('ppad','aut','req'/*,'PAD'*/) -- 'PAD'Added for RKILU-140 
/*Code commented and added by M. Helan on April 21 2025  RPJRB-527 */ 
and cast(doc.tran_date as date)<= isnull(@todate,doc.tran_date) 
--and doc.tran_date between isnull(@fromdate,doc.tran_date) and isnull(@todate,doc.tran_date) 
/*Code commented and added by M. Helan on April 21 2025  RPJRB-527 */ 

and supplier_code in (select distinct supp_spmn_supcode                   
       From Scmdb.dbo.Supp_Spmn_SuplMain (NoLock)                     
       Where isnull(supp_msme_type,'') <> ''   
       and supp_spmn_supcode =isnull(@supplier_code,supp_spmn_supcode))   
and doc.tran_type in ('PM_EV','PM_MI','PM_PI','PM_SCA')   
and doc.doc_status <> 'RVD'   
/*Code commented and Added for PJLMIS_COMP_02 begins */
/*
and doc.tran_ou IN (SELECT DISTINCT OU_id FROM SCMDB..Zrit_Map_Zone_Branch_Nature_dtl WITH (NOLOCK)
WHERE Bu_id	    =isnull(@bu_id,Bu_id)
And	Company_code like @company_id 	/*Code Added for PJLMIS_COMP_02*/
AND Zone	=isnull(@zone,Zone)
AND Branch  =isn

ull(@branch,Branch)
AND OU_id   =isnull(@ou_id,OU_id))
*/
and doc.tran_ou in( Select ou from #user_ou with (nolock) )
/*Code commented and Added for PJLMIS_COMP_02 Ends */

and supp_spmn_supcode =isnull(@supplier_code,supp_spmn_supcode)  
  
union 

select Distinct 
CONVERT(NVARCHAR(100),NULL) 'Company',
	CONVERT(NVARCHAR(200),NULL) 'Bu',
	CONVERT(NVARCHAR(200),NULL) 'Zone',
	CONVERT(NVARCHAR(200),NULL) 'Branch',
	CONVERT(NVARCHAR(200),NULL) 'Nat_bus',
	CONVERT(NVARCHAR(200),NULL) 'Plant_Name',
	CONVERT(NVARCHAR(200),doc.tran_ou) 'OU_Name',
	doc.supplier_code,  
    supp_spmn_supname,  
    supp_msme_type,  
    supp_msme_regno,  
    doc.fb_id,  
    doc.tran_no,   
    convert(varchar(11),doc.tran_date,105) as 'Tran Date',    
    CONVERT(NUMERIC(15,2),doc.tran_amount) as tran_amount,   
    doc.paid_status,   
	CONVERT(NUMERIC(15,2),doc.paid_amount)  paid_amount,   
    CONVERT(NUMERIC(15,2),doc.adjusted_amount) adjusted_amount,   
    CONVERT(NUMERIC(15,2),(isnull(doc.tran_amount,0.00) - isnull(doc.paid_amount,0.00) - isnull(doc.adjusted_amount,0.00))) as 'Balance Amount', 
	CONVERT(NUMERIC(15,2),doc.requested_amount) requested_amount,  
	doc.supp_inv_no,convert(varchar(100),doc.supp_invoice_date,105) as 'Supplier Inv. Date',    
    Convert(varchar(100),doc.component_id) as component_id,  
    convert(Varchar(100),isnull(transfer_date,cdn.transfer_date),105) as 'Anchor Date',   
    'CRE45' as 'Payterm',  
    convert(varchar(100),isnull(transfer_date,cdn.transfer_date) + 45,105) as 'Due Date',  
    convert(varchar(5),isnull((DATEDIFF(Day, Getdate(), (isnull(transfer_date,cdn.transfer_date) + 45))),0))  'OverDue Days'  
    --Code Added for RKILU-140 Begins  
    ,doc.tran_currency   
    ,convert (varchar(120) , null) 'paymentvoucher'  
    ,convert (numeric(28,2) , null) 'paymentvoucheramount'  
    ,convert (varchar(120) , null) 'paymentvoucherdate'  
    --Code Added for RKILU-140 Ends  
 from scmdb..si_doc_hdr doc(nolock)  
 inner join scmdb.dbo.Supp_Spmn_SuplMain (NoLock)    
 on  supplier_code = supp_spmn_supcode  
 inner join scmdb..stn_transfer_bal_hdr cdn(nolock)  
 on cdn.transferee_docno = doc.tran_no  
 and  cdn.ou_id=doc.tran_ou--/*code added by suryakala against RPJRB-859 on 15-05-2025(duplication issue) */

where status in ('A')/*,'PAD'*/ -- 'PAD'Added for RKILU-140  
/*Code commented and added by M. Helan on April 21 2025  RPJRB-527 */ 
--and doc.tran_date between isnull(@fromdate,doc.tran_date) and isnull(@todate,doc.tran_date)  
and cast(doc.tran_date as date) <= isnull(@todate,doc.tran_date)  
/*Code commented and added by M. Helan on April 21 2025  RPJRB-527 */ 

and supplier_code in (select distinct supp_spmn_supcode                   
       From Scmdb.dbo.Supp_Spmn_SuplMain (NoLock)                     
       Where isnull(supp_msme_type,'') <> ''   
       and supp_spmn_supcode =isnull(@supplier_code,supp_spmn_supcode))   
and doc.tran_type in ('PM_EV','PM_MI','PM_PI','PM_SCA','PM_STC') 
and doc.doc_status <> 'RVD'   
/*Code commented and Added for PJLMIS_COMP_02 Begins */
/*
and doc.tran_ou IN (SELECT DISTINCT OU_id FROM SCMDB..Zrit_Map_Zone_Branch_Nature_dtl WITH (NOLOCK)
WHERE Bu_id	    =isnull(@bu_id,Bu_id)
And	Company_code like @company_id 	/*Code Added for PJLMIS_COMP_02*/
AND Zone	=isnull(@zone,Zone)
AND Branch  =isn

ull(@branch,Branch)
AND OU_id   =isnull(@ou_id,OU_id))
*/
and doc.tran_ou in( Select ou from #user_ou with (nolock) )
/*Code commented and Added for PJLMIS_COMP_02 Ends */
and supp_spmn_supcode =isnull(@supplier_code,supp_spmn_supcode)  
    
--Code Added for RKILU-140 Begins  
  
  --return
  
  
select  DISTINCT supppay_account       
into #supppay_account      
from scmdb..ard_supplier_account_mst (Nolock)      
  
select  fb_id,      
  account_code,      
  supplier_code supcust_code,       
  tran_no document_no,      
  Tran_Date posting_date,      
  (sum(case when drcr_flag='cr' then base_amount else base_amount*-1 end)) base_amount,      
  cast(component_id as varchar(200)) component_name,      
  cast(tran_type as varchar(200))  tran_type,      
  exchange_rate,      
  acct_currency,  
  cast('' as varchar(200)) Account_desc      
into #fbp      
from scmdb..Si_acct_info_dtl(nolock)        
where account_code in  (select supppay_account from #supppay_account) 
/*Code commented and added by M. Helan on April 21 2025  RPJRB-527 */ 
--and  posting_date   between @fromdate and @todate   
and  posting_date <= @todate   
/*Code commented and added by M. Helan on April 21 2025  RPJRB-527 */ 

and  company_code =  @company_id  
AND  fbp_post_flag =  'Y'      
and     supplier_code =  isnull(@supplier_code,supplier_code)      
group by fb_id,account_code,supplier_code,tran_no,Tran_Date,component_id,tran_type,exchange_rate,acct_currency      
      
      
select t2.voucher_no,      
  isnull(rp.pay_date,request_date)   'request_date',      
  t2.cr_doc_no,      
  sum(CASE WHEN T1.tran_currency<>'INR' THEN T2.cr_doc_amount ELSE t2.pay_amount END)+sum(isnull(t2.discount,0))+sum(isnull(t2.penalty,0)) pay_amount, -- TO HANDLE MULTIPLE CURRENCY      
  isnull(T3.STATUS,'')STATUS      
into #Payamount      
From #Temp  T1       
join Scmdb.dbo.spy_voucher_dtl  T2 (nolock)      
on  t1.tran_no  = t2.cr_doc_no      
join Scmdb.dbo.spy_voucher_hdr  T3 (nolock)      
On  t2.voucher_no = t3.voucher_no      
and  t2.paybatch_no = t3.paybatch_no   
and  status   in ('PA','RE')  
LEFT join scmdb..rp_voucher_dtl rp (nolock)      
on  t2.voucher_no = rp.voucher_no      
and  t3.voucher_no = rp.voucher_no  
/*Code commented and added by M. Helan on April 21 2025  RPJRB-527 */ 
and  isnull(rp.pay_date,request_date) <= @todate  

--and  isnull(rp.pay_date,request_date) between @fromdate and @todate  
/*Code commented and added by M. Helan on April 21 2025  RPJRB-527 */ 

where t2.voucher_no in ( select document_no    from #fbp      
        where account_code in (select supppay_account from #supppay_account) and tran_type = 'PM_PV'  
        and document_no not in (select voucher_no from scmdb..rp_voucher_dtl(nolock) 
/*Code commented and added by M. Helan on April 21 2025  RPJRB-527 */ 
--where CAST(ISNULL(void_date,PAY_DATE) AS date)  between @fromdate and @todate
where CAST(ISNULL(void_date,PAY_DATE) AS date) <= @todate
/*Code commented and added by M. Helan on April 21 2025  RPJRB-527 */ 


		AND  voucher_status='vd'   
		) -- to remove void transactions      
      )      
group by t2.voucher_no, isnull(rp.pay_date,request_date) , t2.cr_doc_no,isnull(T3.STATUS,'')      
Update T1      
Set  t1.paymentvoucher   = t2.voucher_no,      
  t1.paymentvoucheramount  = t3.pay_amount,      
  t1.paymentvoucherdate  = convert(varchar(11),t2.request_date,105)      
From #Temp   T1       
Join #Payamount T2     
on  T1.tran_no   = T2.cr_doc_no  
Join (select cr_doc_no,sum(pay_amount) pay_amount from #Payamount group by cr_doc_no) t3   
On  T1.tran_no   = T3.cr_doc_no      
and  T2.cr_doc_no   = t3.cr_doc_no      
where T2.STATUS     IN ('PA','RE','PD')    
  
--Code Added for RKILU-140 Ends  
  
 Update a  
Set a.supp_msme_type = paramdesc  
from #Temp a  
inner Join scmdb..component_metadata_table b (nolock)        
on a.supp_msme_type =  paramcode        
where  componentname = 'SUPP'        
and  paramcategory = 'COMBO'        
and  b.paramtype = 'DEFAULT_MSME'   
  
  
Update a  
set a.paid_status = ltrim(rtrim(parameter_text))  
from #Temp a  
inner Join    scmdb..fin_quick_code_met Q with (nolock)      
on  Q.parameter_code = a.paid_status    and    
    Q.parameter_type = 'STATUS'      
 -- and  Q.parameter_category  = 'DOCSTATUS'  --Code commented for RKILU-140  
 and  Q.component_id  = a.component_id --Code uncommented for RKILU-140  
  and  Q.language_id  = 1   
  
Update #Temp  
set component_id = ComponentDesc  
from #Temp  
inner join scmdb..fw_admin_view_component  
on component_id  = componentname  
  
		UPDATE	T
		SET		zone	=	paramdesc,
				branch	=	a.branch,
				BU		=	a.Bu_Name,
				Company	=	Company_Name
		FROM	scmdb..Zrit_Map_Zone_Branch_Nature_dtl a WITH (NOLOCK)
		JOIN	#Temp T
		ON		T.OU_Name = a.OU_id
		JOIN	scmdb..component_metadata_table WITH(NOLOCK) 
		ON		a.[Zone]		= paramcode
		AND		componentname	= 'EMOD'   
		AND		paramcategory	= 'COMBO'   
		AND		paramtype		= 'ZONE'
		and		langid			=	1	/*Code Added for PJLMIS_COMP_02 */

 
		UPDATE	T
		SET		nat_bus = paramdesc
		FROM	scmdb..Zrit_Map_Zone_Branch_Nature_dtl a WITH(NOLOCK) 
		JOIN	#Temp T
		ON		T.OU_Name = a.OU_id 
		JOIN	scmdb..component_metadata_table WITH(NOLOCK) 
		ON		a.Nature_of_business = paramcode
		AND		componentname	= 'EMOD'   
		AND		paramcategory	= 'COMBO'   
		AND		paramtype		= 'NATURE'
		and		langid			=	1	/*Code Added for PJLMIS_COMP_02 */

		UPDATE	T
		SET		Plant_Name	=	OUInstDesc,
				OU_Name		=	OUinstName
		FROM	#Temp T
		JOIN	depdb..fw_admin_ouinstance loc (nolock)      
        on		loc.ouinstid	=	T.OU_Name

SELECT *
FROM #Temp
ORDER BY CONVERT(DATE, [Tran Date], 103) DESC 
  
 End
