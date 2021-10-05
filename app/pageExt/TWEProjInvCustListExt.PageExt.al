/// <summary>
/// PageExtension TWE Proj. Inv. Cust. List Ext. (ID 50003) extends Record Customer List.
/// </summary>
pageextension 50003 "TWE Proj. Inv. Cust. List Ext." extends "Customer List"
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
