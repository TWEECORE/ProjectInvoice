/// <summary>
/// Page TWE Proj. Inv. Imports (ID 50000).
/// </summary>
page 50000 "TWE PI Projects to Invoice"
{
    ApplicationArea = All;
    Caption = 'Project Invoice Projects to Invoice';
    PageType = List;
    SourceTable = "TWE Proj. Inv. Project";
    UsageCategory = Lists;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTableView = sorting(ID) order(ascending) where("All Hours invoiced" = filter(= false));
    CardPageID = "TWE Proj. Inv. Project Card";
    AdditionalSearchTerms = 'project,invoice,projects,tweecore';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(ID; Rec.ID)
                {
                    ToolTip = 'Specifies the ID of this project.';
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the project name.';
                    ApplicationArea = All;
                }
                field("Related to Customer No."; Rec."Related to Customer No.")
                {
                    ToolTip = 'Specifies the customer no. related to this project.';
                    ApplicationArea = All;
                }
                field("Related to Customer Name"; Rec."Related to Customer Name")
                {
                    ToolTip = 'Specifies the customer name related to this project.';
                    ApplicationArea = All;
                }
                field("Total Work Hours"; Rec."Total Work Hours")
                {
                    ToolTip = 'Specifies the total amount of all working hours done during this project.';
                    ApplicationArea = All;
                }
                field("Invoice Type"; rec."Invoice Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Object Type that should be used to invoice project hours';
                }
                field("No."; rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'No. of object to be invoiced.';
                }
                field("Use Standard Hourly Rate"; rec."Use Standard Hourly Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if a standard hourly rate should be used for invoicing.';
                }
                field("Standard Hourly Rate"; rec."Standard Hourly Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the standard hourly rate used for invoicing this projects working hours.';
                }
                field("Project Mgt. System"; rec."Project Mgt System")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the linked Project Mgt. System.';
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetHours)
            {
                ApplicationArea = All;
                Caption = 'Import Project Hours';
                ToolTip = 'Imports project hours from project management systems.';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Report.Run(Report::"TWE Proj. Inv. Import");
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        rec.CalcFields(rec."Total Work Hours");
    end;

    trigger OnOpenPage()
    var
        project: Record "TWE Proj. Inv. Project";
        projectHour: Record "TWE Proj. Inv. Project Hours";
    begin
        if project.FindSet() then
            repeat
                projectHour.Reset();
                projectHour.SetRange("Project ID", project.ID);
                projectHour.SetRange(Invoiced, false);
                if projectHour.IsEmpty() then
                    project."All Hours invoiced" := true
                else
                    project."All Hours invoiced" := false;
                project.Modify();
            until project.Next() = 0;
    end;
}
