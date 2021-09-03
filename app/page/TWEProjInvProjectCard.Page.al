/// <summary>
/// Page TWE Proj. Inv. Project Card (ID 70704958).
/// </summary>
page 70704958 "TWE Proj. Inv. Project Card"
{

    Caption = 'Proj. Inv. Project Card';
    PageType = Card;
    SourceTable = "TWE Proj. Inv. Project";

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
                field("Related to Customer Name"; Rec."Related to Customer Name")
                {
                    ToolTip = 'Specifies the value of the Related to Customer Name field';
                    ApplicationArea = All;
                }
                field("Related to Customer No."; Rec."Related to Customer No.")
                {
                    ToolTip = 'Specifies the value of the Related to Customer No. field';
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
                    ApplicationArea = All;
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
                action(InvoiceOpenHours)
                {
                    ApplicationArea = All;
                    Caption = 'Process Project Times';
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Image = CheckJournal;
                    ToolTip = 'Process Project Times';

                    trigger OnAction()
                    var
                        projInvProcessingMgt: Codeunit "TWE Proj. Inv. Processing Mgt";
                    begin
                        projInvProcessingMgt.InvoiceUnprocessedProjectHours(Rec);
                    end;
                }
            }
        }

    }
}
