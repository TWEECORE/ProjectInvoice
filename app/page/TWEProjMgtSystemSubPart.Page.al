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
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = All;
                }
                field("TWE Project Mgt. System"; Rec."TWE Project Mgt. System")
                {
                    ToolTip = 'Specifies the value of the Project Mgt. System field';
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
                    ToolTip = 'Specifies the value of the Endpoint field';
                    ApplicationArea = All;
                }
                field("TWE Timetracking Endpoint"; rec."TWE PI Timetracking Endpoint")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the endpoint used to gain timetracking data from a Project Mgt. System';
                }
                field("User Name"; Rec."User Name")
                {
                    ToolTip = 'Specifies the value of the User Name field';
                    ApplicationArea = All;
                }
                field(Password; Rec.Password)
                {
                    ToolTip = 'Specifies the value of the Password field';
                    ApplicationArea = All;
                }
                field("TWE Proj. Inv. PermToken"; Rec."TWE Proj. Inv. PermToken")
                {
                    ToolTip = 'Specifies the value of the Permanent Token field';
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
                    ToolTip = 'Specifies the value of the registered timetracking permanent token';
                    ExtendedDatatype = Masked;
                }
            }
        }
    }
}
