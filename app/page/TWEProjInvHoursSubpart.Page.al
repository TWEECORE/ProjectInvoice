/// <summary>
/// Page TWE Proj. Inv. Hours Subpart (ID 70704955).
/// </summary>
page 70704955 "TWE Proj. Inv. Hours Subpart"
{
    Caption = ' ';
    PageType = ListPart;
    SourceTable = "TWE Proj. Inv. Project Hours";
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTableView = sorting(ID) order(ascending) where(Invoiced = filter(= false));

    layout
    {
        area(content)
        {
            repeater(General)
            {
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
    actions
    {
        area(Processing)
        {
            group(Invoice)
            {
                action(InvoiceSelectedOpenHours)
                {
                    ApplicationArea = All;
                    Caption = 'Invoice selected Project Hours';
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Image = CheckJournal;
                    ToolTip = 'Creates an Invoice for the selected Project Hours';

                    trigger OnAction()
                    var
                        projectHour: Record "TWE Proj. Inv. Project Hours";
                        projInvProcessingMgt: Codeunit "TWE Proj. Inv. Processing Mgt";
                    begin
                        CurrPage.SetSelectionFilter(projectHour);
                        if projectHour.FindSet() then
                            projInvProcessingMgt.InvoiceProjectHours(projectHour);
                    end;
                }
            }
        }

    }
}