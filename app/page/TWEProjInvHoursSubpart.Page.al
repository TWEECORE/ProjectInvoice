/// <summary>
/// Page TWE Proj. Inv. Hours Subpart (ID 70704955).
/// </summary>
page 70704955 "TWE Proj. Inv. Hours Subpart"
{
    Caption = 'Proj. Inv. Hours';
    PageType = ListPart;
    SourceTable = "TWE Proj. Inv. Project Hours";

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
                    ToolTip = 'Specifies the value of the Ticket ID field';
                    ApplicationArea = All;
                }
                field("Ticket Name"; Rec."Ticket Name")
                {
                    ToolTip = 'Specifies the value of the Ticket Name field';
                    ApplicationArea = All;
                }
                field("Work Description"; Rec."Work Description")
                {
                    ToolTip = 'Specifies the value of the Work Description field';
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
                field(Invoiced; Rec.Invoiced)
                {
                    ToolTip = 'Specifies the value of the Invoiced field';
                    ApplicationArea = All;
                }
            }
        }
    }

}
