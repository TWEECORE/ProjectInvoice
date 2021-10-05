/// <summary>
/// PageExtension TWE Proj. Inv. Cust. Card Ext. (ID 50002) extends Record Customer Card.
/// </summary>
pageextension 50002 "TWE Proj. Inv. Cust. Card Ext." extends "Customer Card"
{
    layout
    {

    }

    actions
    {
        addafter("&Customer")
        {
            action("TWE Proj. Inv. Customer Projects")
            {
                Caption = 'Projects';
                Image = NewItem;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Opens a page with customer related projects';

                trigger OnAction()
                var
                    customerProject: Record "TWE Proj. Inv. Project";
                    customerProjectsPage: Page "TWE Proj. Inv. Projects";
                begin
                    customerProject.SetRange("Related to Customer No.", Rec."No.");
                    if customerProject.FindSet() then begin
                        customerProjectsPage.SetRecord(customerProject);
                        customerProjectsPage.RunModal();
                    end;
                end;
            }
        }
    }

}
