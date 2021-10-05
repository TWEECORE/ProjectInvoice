/// <summary>
/// Codeunit TWE Proj. Inv. Install (ID 50001).
/// </summary>
codeunit 50001 "TWE Proj. Inv. Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        initData();
    end;

    local procedure initData()
    var
        ProjInvSetup: Record "TWE Proj. Inv. Setup";
        reportSelections: Record "Report Selections";
        BaseMgt: Codeunit "TWE Base Mgt";
        upgradeTag: Codeunit "Upgrade Tag";
        myAppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(myAppInfo);

        if myAppInfo.DataVersion = Version.Create(0, 0, 0, 0) then begin
            ProjInvSetup.GetSetup();
            BaseMgt.InstallApp("TWE Apps"::"Project Invoice", Format(myAppInfo.AppVersion));

            if not reportSelections.Get(reportSelections.Usage::"TWE PI Project Hours", 1) then begin
                reportSelections.Init();
                reportSelections.Usage := reportSelections.Usage::"TWE PI Project Hours";
                reportSelections.Sequence := '1';
                reportSelections."Report ID" := 70704951;
                reportSelections."Report Caption" := 'Project Invoice Service Report';
                reportSelections."Email Body Layout Type" := reportSelections."Email Body Layout Type"::"Custom Report Layout";
                reportSelections.Insert();
            end;
        end else
            handleReInstall();

        upgradeTag.SetAllUpgradeTags();
    end;

    local procedure handleReInstall()
    var
    begin
        //empty function
    end;
}
