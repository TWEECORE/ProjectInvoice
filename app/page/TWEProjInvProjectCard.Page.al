/// <summary>
/// Page TWE Proj. Inv. Project Card (ID 70704958).
/// </summary>
page 70704958 "TWE Proj. Inv. Project Card"
{

    Caption = 'Proj. Inv. Project Card';
    PageType = Card;
    SourceTable = "TWE Proj. Inv. Project";
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(ID; Rec.ID)
                {
                    ToolTip = 'Specifies the value of the ID field';
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = All;
                }
                field("Related to Customer No."; Rec."Related to Customer No.")
                {
                    ToolTip = 'Specifies the value of the Related to Customer No. field';
                    ApplicationArea = All;
                }
                field("Related to Customer Name"; Rec."Related to Customer Name")
                {
                    ToolTip = 'Specifies the value of the Related to Customer Name field';
                    ApplicationArea = All;
                }
                field("Total Work Hours"; Rec."Total Work Hours")
                {
                    ToolTip = 'Specifies the value of the Total Work Hours field';
                    ApplicationArea = All;
                }
                field("Invoice Type"; rec."Invoice Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Invoice Type that should be used to invoice project hours';
                }
                field("No."; rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'No. of object to be invoiced';
                }
                field("Summarize Times for Invoice"; rec."Summarize Times for Invoice")
                {
                    ApplicationArea = All;
                    ToolTip = 'Defines whether all invoiced project times should be summarized';
                }
                field("Summarized Description"; rec."Summarized Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Defines summarized description';
                }
                field("Project Mgt. System"; rec."Project Mgt System")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the linked Project Mgt. System';
                }
            }
            group(Invoicing)
            {
                field("Use Standard Hourly Rate"; rec."Use Standard Hourly Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if a standard hourly rate should be used for invoicing';
                }
                field("Standard Hourly Rate"; rec."Standard Hourly Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the standard hourly rate';
                }
            }
            group("Work Hours")
            {
                part(RelatedHours; "TWE Proj. Inv. Hours Subpart")
                {
                    ApplicationArea = Basic, Suite;
                    SubPageLink = "Project ID" = field(ID);
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            group(Invoice)
            {
                action(InvoiceAllOpenHours)
                {
                    ApplicationArea = All;
                    Caption = 'Invoice all Project Hours';
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Image = CheckJournal;
                    ToolTip = 'Creates an Invoice for the current Project Hours';

                    trigger OnAction()
                    var
                        projInvProcessingMgt: Codeunit "TWE Proj. Inv. Processing Mgt";
                    begin
                        projInvProcessingMgt.InvoiceProject(Rec);
                    end;
                }
            }
        }

    }
}
