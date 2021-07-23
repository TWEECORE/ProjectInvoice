page 70704957 "TWE Proj. Inv. API Data"
{
    ApplicationArea = All;
    Caption = 'Proj. Inv. API Data';
    PageType = List;
    SourceTable = "TWE Proj. Mgt. System API Data";
    UsageCategory = Lists;

    //TODO:Tooltip anpassen
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(ID; Rec.ID)
                {
                    ToolTip = 'Specifies the value of the ID field';
                    ApplicationArea = All;
                }
                field("System Name"; Rec."System Name")
                {
                    ToolTip = 'Specifies the value of the System Name field';
                    ApplicationArea = All;
                }
                field("Authentication Type"; Rec."Authentication Type")
                {
                    ToolTip = 'Specifies the value of the Authentication Type field';
                    ApplicationArea = All;
                }
                field("API URI"; Rec."API URI")
                {
                    ToolTip = 'Specifies the value of the API URI field';
                    ApplicationArea = All;
                }
                field("API Key"; Rec."API Key")
                {
                    ToolTip = 'Specifies the value of the API Key field';
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                }
                field("API Access Token"; Rec."API Access Token")
                {
                    ToolTip = 'Specifies the value of the API Access Token field';
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                }
            }
        }
    }

}
