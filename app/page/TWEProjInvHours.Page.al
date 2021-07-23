page 70704956 "TWE Proj. Inv. Hours"
{
    ApplicationArea = All;
    Caption = 'Proj. Inv. Hours';
    PageType = List;
    SourceTable = "TWE Project Hours";
    UsageCategory = Lists;

    //TODO: ToolTips anpassen
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
                field("Ticket No."; Rec."Ticket No.")
                {
                    ToolTip = 'Specifies the value of the Ticket No. field';
                    ApplicationArea = All;
                }
                field("Project ID"; Rec."Project ID")
                {
                    ToolTip = 'Specifies the value of the Project ID field';
                    ApplicationArea = All;
                }
                field(Hours; Rec.Hours)
                {
                    ToolTip = 'Specifies the value of the Hours field';
                    ApplicationArea = All;
                }
                field(Agent; Rec.Agent)
                {
                    ToolTip = 'Specifies the value of the Agent field';
                    ApplicationArea = All;
                }
            }
        }
    }

}
