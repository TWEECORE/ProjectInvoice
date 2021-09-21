/// <summary>
/// Page TWE Proj. Mgt. System SubPart (ID 70704957).
/// </summary>
page 70704957 "TWE Proj. Mgt. System SubPart"
{
    Caption = ' ';
    PageType = ListPart;
    SourceTable = "TWE OAuth 2.0 Application";
    //SourceTableView = sorting(code) order(ascending) where("TWE Is Project Mgt. System" = filter(= true));

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the API Application Code.';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the API Application.';
                    ApplicationArea = All;
                }
                field("TWE Project Mgt. System"; Rec."TWE Project Mgt. System")
                {
                    ToolTip = 'Specifies the type of Project Mgt. System.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if rec."TWE Project Mgt. System" <> rec."TWE Project Mgt. System"::" " then
                            rec.Validate("TWE Is Project Mgt. System", true)
                        else
                            rec.Validate("TWE Is Project Mgt. System", false);
                    end;
                }
                field("TWE Proj. Inv. Endpoint"; Rec."TWE Proj. Inv. Endpoint")
                {
                    ToolTip = 'Specifies the Endpoint URI for the API Application.';
                    ApplicationArea = All;
                }
                field("TWE Timetracking Endpoint"; rec."TWE PI Timetracking Endpoint")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Endpoint URI for a different timetracking application, if needed.';
                }
                field("User Name"; Rec."User Name")
                {
                    ToolTip = 'Specifies the name of the user registered for the API Application.';
                    ApplicationArea = All;
                }
                field(Password; Rec.Password)
                {
                    ToolTip = 'Should contain the users password.';
                    ApplicationArea = All;
                }
                field("TWE Proj. Inv. PermToken"; Rec."TWE Proj. Inv. PermToken")
                {
                    ToolTip = 'Specifies the value of the Permanent Token generated at the API applications side.';
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;

                    trigger OnValidate()
                    begin
                        if rec."TWE Proj. Inv. PermToken" <> '' then
                            rec.Validate("TWE Use Permanent Token", true)
                        else
                            rec.Validate("TWE Use Permanent Token", false);
                    end;
                }
                field("TWE PI TimeTrackingPermToken"; rec."TWE PI Timetracking PermToken")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the registered timetracking permanent token generated at the Timetracking applications side.';
                    ExtendedDatatype = Masked;
                }
            }
        }
    }
}
