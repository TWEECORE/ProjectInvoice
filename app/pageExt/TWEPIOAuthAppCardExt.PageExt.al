pageextension 70704952 "TWE PI OAuth AppCard Ext." extends "TWE OAuth 2.0 Application"
{
    layout
    {
        // Adding a new control field 'ShoeSize' in the group 'General'
        addlast(General)
        {
            field("TWE Use Project Mgt System"; rec."TWE Use Project Mgt. System")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether the oAuth data is related to a Project Mgt. System';

                trigger OnValidate()
                begin

                end;
            }
            field("TWE Project Mgt. System"; rec."TWE Project Mgt. System")
            {
                ApplicationArea = All;
                Visible = TWEProjMgtSystemVisible;
                ToolTip = 'Specifies the name of the Project Mgt. System';
            }
            field("TWEUse Permanent Token"; rec."TWE Use Permanent Token")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether the permanent token should be used for authentication';

                trigger OnValidate()
                begin

                end;
            }
            field("TWE Proj. Inv. PermToken"; rec."TWE Proj. Inv. PermToken")
            {
                ApplicationArea = All;

                ToolTip = 'Specifies the value of the registered permanent token';
                ExtendedDatatype = Masked;
            }
        }
        addlast(Endpoints)
        {
            field("TWE Proj. Inv. Endpoint"; rec."TWE Proj. Inv. Endpoint")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the endpoint used to gain data from a Project Mgt. System';
            }
        }
    }

    trigger OnOpenPage()
    begin
        TWEProjMgtSystemVisible := rec.TWEGetProjMgtSystemVisible();
        TWEPermTokenVisible := rec.TWEGetPermTokenVisible();
    end;

    var
        TWEProjMgtSystemVisible: Boolean;
        TWEPermTokenVisible: Boolean;
}
