/// <summary>
/// Page TWE Proj. Inv. Setup (ID 50006).
/// </summary>
page 50006 "TWE Proj. Inv. Setup"
{
    Caption = 'Project Invoice Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "TWE Proj. Inv. Setup";
    AdditionalSearchTerms = 'project,invoice,tweecore';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Invoice Type"; rec."Invoice Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Object Type that should be used to invoice project hours';
                }
                field("No."; rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'No. of object to be invoiced';
                }
                field("No. Series for PI Invoices"; rec."No. Series for Proj. Invoices")
                {
                    ApplicationArea = All;
                    ToolTip = 'Defines No. Series for Project Invoice Invoices';
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
                field("Always attach Service Report"; rec."Always Attach Service Report")
                {
                    ApplicationArea = All;
                    ToolTip = 'Determines whether each PI Invoice receives a service report as an attachment';
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
