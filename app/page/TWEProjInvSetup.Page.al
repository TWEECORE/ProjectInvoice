page 70704950 "TWE Proj. Inv. Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "TWE Proj. Inv. Setup";

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field("GL Account"; rec."G/L Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'G/L Account No. that should be used to invoice project hours';
                }
                field("No. Series for Import"; rec."No. Series for Import")
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