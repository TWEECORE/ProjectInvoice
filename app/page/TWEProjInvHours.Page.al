/// <summary>
/// Page TWE Proj. Inv. Hours (ID 50001).
/// </summary>
page 50001 "TWE Proj. Inv. Hours"
{
    Caption = 'Project Invoice ProjectHours';
    PageType = List;
    SourceTable = "TWE Proj. Inv. Project Hours";
    InsertAllowed = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(ID; Rec.ID)
                {
                    ToolTip = 'Specifies the ID of the project hour entry.';
                    ApplicationArea = All;
                }
                field("Ticket ID"; Rec."Ticket ID")
                {
                    ToolTip = 'Specifies ID of the related Ticket.';
                    ApplicationArea = All;
                }
                field("Ticket Name"; Rec."Ticket Name")
                {
                    ToolTip = 'Specifies the related Ticket Name.';
                    ApplicationArea = All;
                }
                field("Project ID"; Rec."Project ID")
                {
                    ToolTip = 'Specifies the value of the Project ID field';
                    ApplicationArea = All;
                }
                field("Work Description"; Rec."Work Description")
                {
                    ToolTip = 'Specifies the Work Description.';
                    ApplicationArea = All;
                }
                field(Hours; Rec.Hours)
                {
                    ToolTip = 'Specifies the needed Hours.';
                    ApplicationArea = All;
                }
                field("Hours to Invoice"; Rec."Hours to Invoice")
                {
                    ToolTip = 'Specifies the value of the amount of Hours that should be invoiced.';
                    ApplicationArea = All;
                }
                field(Agent; Rec.Agent)
                {
                    ToolTip = 'Specifies the working agent.';
                    ApplicationArea = All;
                }
                field(Invoiced; Rec.Invoiced)
                {
                    ToolTip = 'Specifies whether this project hour is already invoiced.';
                    ApplicationArea = All;
                }
                field("Working Date"; Rec."Working Date")
                {
                    ToolTip = 'Specified the date of the work done.';
                    ApplicationArea = All;
                }
            }
        }
    }

}
