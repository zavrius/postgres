set nocount on

declare @AsymKey nvarchar(100) = N'EtereLicSign'
declare @result int = 0
declare @msg nvarchar(max) = ''
declare @LangId int = 2

if @result = 0
begin
    if not exists(select name from sys.asymmetric_keys with (nolock) where name = @AsymKey)
    begin
        set @result = -100
        set @msg = dbo.Translate('AsymKey Error code -100', @LangId)+' "'+@AsymKey+'"'
        +char(13)+char(10)+dbo.Translate('Eseguire la manutenzione archivi', @LangId)
    end
end

if @result = 0
begin
    if (select VerifySignedByAsymKey(AsymKey_ID(@AsymKey), cast('Etere check string' as nvarchar(20)),cast(0x5D64EB514A30640C0CCA05CE0B6858609E7D014662B54C830A0C8CCEECD3C8814F2053448D38588C0B01C456731689808ABA5BFE16D6EF47A39315D6293E8DD15612D773680E7172371C8F837B3F197184A48214ECD3D31E5143BB8BDAEAF9E7B4F7748DF5B65B7E9F6D3F5608CAA7D41C3C4D79D7D0211F8352D6725CBD2F5A as varbinary(max)))) = 0
    begin
        set @result = -200
        set @msg = dbo.Translate('AsymKey Error code -200', @LangId)+' "'+@AsymKey+'"'
        +char(13)+char(10)+dbo.Translate('Eseguire la manutenzione archivi', @LangId)
    end
end

if @result = 0
begin
    if not exists(select cod_user from users with (nolock))
    begin
        set @result = -210
        set @msg = dbo.Translate('AsymKey Error code -210', @LangId)
        +char(13)+char(10)+dbo.Translate('Eseguire "Aggiornamento licenze"', @LangId)
    end
end

if @result = 0
begin
    begin try
        if exists(select cod_user from users with (nolock) where verifySignedByAsymKey(AsymKey_Id(@AsymKey),[value],[sign]) <= 0)
            set @result = -1
    end try
    begin catch
        set @result = -1
    end catch
    if @result = -1
    begin
        begin try
            if not exists(select cod_user from users with (nolock) where verifySignedByAsymKey(AsymKey_Id(@AsymKey), cast([value] as varchar(max)),[sign]) <= 0)
                set @result = 0
        end try
        begin catch
        end catch
    end
    if @result = -1
        set @msg = dbo.Translate('AsymKey Error code -1', @LangId) +char(13)+char(10)+ dbo.Translate('Eseguire "Aggiornamento licenze"', @LangId)
end

if @result = 0
begin
    begin try
        if exists(select [value] from rs_resources with (nolock) where verifySignedByAsymKey(AsymKey_Id(@AsymKey),[value],[sign]) <= 0)
            set @result = -2
    end try
    begin catch
        set @result = -2
    end catch
    if @result = -2
    begin
        begin try
            if not exists(select [value] from rs_resources with (nolock) where verifySignedByAsymKey(AsymKey_Id(@AsymKey),cast([value] as varchar(max)),[sign]) <= 0)
                set @result = 0
        end try
        begin catch
        end catch
    end
    if @result = -2
        set @msg =  dbo.Translate('AsymKey Error code -2', @LangId) +char(13)+char(10)+ dbo.Translate('Eseguire "Aggiornamento licenze"', @LangId)
end

if @result = 0
begin
    declare @LicenceVer int = dbo.StrToIntDef(dbo.split((select top 1 cast([value] as xml).value('(/header/@Version)[1]', 'nvarchar(100)') from users with (nolock) order by cod_user),'.',0),-1)
    declare @ApplicationVer int = 35
    if @LicenceVer < @ApplicationVer
    begin
        set @result = -3
        set @msg=          dbo.Translate('La licenza installata Ë utilizzabile per la versione di Etere:', @LangId)+' '+cast(@LicenceVer as nvarchar(10))
        +char(13)+char(10)+dbo.Translate('mentre si sta utilizzando la versione di Etere:', @LangId)+' '+cast(@ApplicationVer as nvarchar(10))
        +char(13)+char(10)+dbo.Translate('Eseguire "Aggiornamento licenze"', @LangId)
    end
end

if @result = 0
begin
    declare @PcInstalled int = ISNULL((select count(id_workstations) from workstations with (nolock)),0)
    if not exists(select id_workstations from workstations with(nolock) where pcname = N'MIRCOW10')
        set @PcInstalled = @PcInstalled + 1
    declare @PcAvailable int = dbo.get_checkCodeInLicence('ET2001', 1)
    if @PcInstalled > @PcAvailable
    begin
        set @result = -4
        set @msg =         dbo.Translate('Non posso aggiungere un nuovo PC al sistema', @LangId)
        +char(13)+char(10)+dbo.Translate('UTENTI COLLEGABILI=', @LangId) + cast(@PcAvailable as nvarchar(20))
        +char(13)+char(10)+dbo.Translate('UTENTI COLLEGATI=', @LangId) + cast(@PcInstalled as nvarchar(20))
    end
end

if @result <> 0
begin
    set @msg = dbo.Translate('Impossibile avviare il programma', @LangId)
    +char(13)+char(10)+ @msg
    +char(13)+char(10)+ dbo.Translate('Error code', @LangId)+': ' + cast(@result as nvarchar(10))
    raiserror(@msg, 17, 1)
end

select @result error_code, @msg error_message
