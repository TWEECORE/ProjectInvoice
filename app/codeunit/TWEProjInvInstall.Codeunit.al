/// <summary>
/// Codeunit TWE Proj. Inv. Install (ID 70704950).
/// </summary>
codeunit 70704950 "TWE Proj. Inv. Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        initData();
    end;


    local procedure initData()
    var
        BaseMgt: Codeunit "TWE Base Mgt";
        upgradeTag: Codeunit "Upgrade Tag";
        myAppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(myAppInfo);

        if myAppInfo.DataVersion = Version.Create(0, 0, 0, 0) then
            BaseMgt.InstallApp("TWE Apps"::"Project Invoice", Format(myAppInfo.AppVersion))
        else
            handleReInstall();

        upgradeTag.SetAllUpgradeTags();
    end;

    local procedure handleReInstall()
    var
    begin
        //empty function
    end;
}