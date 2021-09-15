/// <summary>
/// Page TWE Proj. Inv. Hours (ID 70704956).
/// </summary>
page 70704956 "TWE Proj. Inv. Hours"
{
    Caption = 'Proj. Inv. Hours';
    PageType = List;
    SourceTable = "TWE Proj. Inv. Project Hours";
    InsertAllowed = false;

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
                field("Ticket ID"; Rec."Ticket ID")
                {
                    ToolTip = 'Specifies the value of the Ticket No. field';
                    ApplicationArea = All;
                }
                field("Ticket Name"; Rec."Ticket Name")
                {
                    ToolTip = 'Specifies the value of the Ticket Name field';
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
                field("Hours to Invoice"; Rec."Hours to Invoice")
                {
                    ToolTip = 'Specifies the value of the amount of Hours that should be invoiced';
                    ApplicationArea = All;
                }
                field(Agent; Rec.Agent)
                {
                    ToolTip = 'Specifies the working agent';
                    ApplicationArea = All;
                }
                field(Invoiced; Rec.Invoiced)
                {
                    ToolTip = 'Specifies whether this project hour is already invoiced';
                    ApplicationArea = All;
                }
                field("Working Date"; Rec."Working Date")
                {
                    ToolTip = 'Working Date';
                    ApplicationArea = All;
                }
            }
        }
    }

}
