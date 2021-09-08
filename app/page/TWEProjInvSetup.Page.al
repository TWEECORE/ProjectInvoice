/// <summary>
/// Page TWE Proj. Inv. Setup (ID 70704950).
/// </summary>
page 70704950 "TWE Proj. Inv. Setup"
{
    Caption = 'Project Invoice Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "TWE Proj. Inv. Setup";

    layout
    {
        area(Content)
        {
            group(General)
            {
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
                field("No. Series for Import"; rec."No. Series for Proj. Invoices")
                {
                    ApplicationArea = All;
                    ToolTip = 'No. Series for Imported project data';
                }
            }
        }
    }
    /*
    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }
    */
}