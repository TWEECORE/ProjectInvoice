/// <summary>
/// Page TWE Proj. Inv. Import Lines (ID 70704953).
/// </summary>
page 70704953 "TWE Proj. Inv. Import Lines"
{
    Caption = 'Proj. Inv. Import Lines';
    PageType = List;
    SourceTable = "TWE Proj. Inv. Import Line";
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(LineNo; Rec."Line No")
                {
                    ToolTip = 'Specifies the value of the ID field';
                    ApplicationArea = All;
                }
                field("Import Header ID"; Rec."Import Header ID")
                {
                    ToolTip = 'Specifies the value of the Import Header ID field';
                    ApplicationArea = All;
                }
                field("Project ID"; Rec."Project ID")
                {
                    ToolTip = 'Specifies the value of the Project ID field';
                    ApplicationArea = All;
                }
                field("Project Name"; Rec."Project Name")
                {
                    ToolTip = 'Specifies the value of the Project Name field';
                    ApplicationArea = All;
                }
                field("Project Description"; Rec."Project Mgt. System")
                {
                    ToolTip = 'Specifies the value of the Project Description field';
                    ApplicationArea = All;
                }
                field("Ticket No."; Rec."Ticket No.")
                {
                    ToolTip = 'Specifies the value of the Ticket No. field';
                    ApplicationArea = All;
                }
                field("Ticket Name"; Rec."Ticket Name")
                {
                    ToolTip = 'Specifies the value of the Ticket Name field';
                    ApplicationArea = All;
                }
                field("Ticket Created at"; Rec."Ticket Created at")
                {
                    ToolTip = 'Specifies the creation date of the ticket';
                    ApplicationArea = All;
                }
                field("WorkItem ID"; Rec."WorkItem ID")
                {
                    ToolTip = 'Specifies the ID of the WorkItem';
                    ApplicationArea = All;
                }
                field("WorkItem Description"; Rec."WorkItem Description")
                {
                    ToolTip = 'Specifies the description of the WorkItem';
                    ApplicationArea = All;
                }
                field("WorkItem Created at"; Rec."WorkItem Created at")
                {
                    ToolTip = 'Specifies the creation date of th work item';
                    ApplicationArea = All;
                }
                field(Hours; Rec.Hours)
                {
                    ToolTip = 'Specifies the value of the Hours field';
                    ApplicationArea = All;
                }
                field(Agent; Rec.Agent)
                {
                    ToolTip = 'Specifies the value of the agent field';
                    ApplicationArea = All;
                }
                field("Ticket Creator"; Rec."Ticket Creator")
                {
                    ToolTip = 'Specifies the value of the ticket creator field';
                    ApplicationArea = All;
                }
                field(Imported; Rec.Imported)
                {
                    ToolTip = 'Specifies the value of the Imported field';
                    ApplicationArea = All;
                }
            }
        }
    }

}
