page 70704955 "TWE Proj. Inv. Tickets"
{
    ApplicationArea = All;
    Caption = 'Proj. Inv. Tickets';
    PageType = List;
    SourceTable = "TWE Project Ticket";
    UsageCategory = Lists;

    //TODO: Tooltips anpassen
    layout
    {
        area(content)
        {
            repeater(General)
            {
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
                field("Ticket Name"; Rec."Ticket Name")
                {
                    ToolTip = 'Specifies the value of the Ticket Name field';
                    ApplicationArea = All;
                }
                field("Ticket Status"; Rec."Ticket Status")
                {
                    ToolTip = 'Specifies the value of the Ticket Status field';
                    ApplicationArea = All;
                }
                field("Total Hours"; Rec."Total Hours")
                {
                    ToolTip = 'Specifies the value of the Total Hours field';
                    ApplicationArea = All;
                }
            }
        }
    }

}
