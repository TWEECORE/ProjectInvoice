/// <summary>
/// Page TWE Proj. Mgt. System SubPart (ID 70704957).
/// </summary>
page 70704957 "TWE Proj. Mgt. System SubPart"
{
    Caption = 'Project Management Systems';
    PageType = ListPart;
    SourceTable = "TWE OAuth 2.0 Application";

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
                        if (rec."TWE Project Mgt. System" = rec."TWE Project Mgt. System"::"JIRA Tempo") or
                            (rec."TWE Project Mgt. System" = rec."TWE Project Mgt. System"::YoutTrack) then
                            rec.Validate("TWE Use Project Mgt. System", true)
                        else
                            rec.Validate("TWE Use Project Mgt. System", false);
                    end;
                }
                field("TWE Proj. Inv. Endpoint"; Rec."TWE Proj. Inv. Endpoint")
                {
                    ToolTip = 'Specifies the value of the Endpoint field';
                    ApplicationArea = All;
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

                    trigger OnValidate()
                    begin
                        if rec."TWE Proj. Inv. PermToken" <> '' then
                            rec.Validate("TWE Use Permanent Token", true)
                        else
                            rec.Validate("TWE Use Permanent Token", false);
                    end;
                }

                field("Access Token URL"; Rec."Access Token URL")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Access Token URL field';
                    ApplicationArea = All;
                }
                field("Authorization URL"; Rec."Authorization URL")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Authorization URL field';
                    ApplicationArea = All;
                }
                field("Auth. URL Parms"; Rec."Auth. URL Parms")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Auth. URL Parms field';
                    ApplicationArea = All;
                }
                field("Client ID"; Rec."Client ID")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Client ID field';
                    ApplicationArea = All;
                }
                field("Client Secret"; Rec."Client Secret")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Client Secret field';
                    ApplicationArea = All;
                }
                field("Expires In"; Rec."Expires In")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Expires In field';
                    ApplicationArea = All;
                }
                field("Redirect URL"; Rec."Redirect URL")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Redirect URL field';
                    ApplicationArea = All;
                }
                field("Grant Type"; Rec."Grant Type")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Grant Type field';
                    ApplicationArea = All;
                }
            }
        }
    }
}
