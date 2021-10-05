/// <summary>
/// Page TWE Proj. Inv. Projects (ID 50005).
/// </summary>
page 50005 "TWE Proj. Inv. Projects"
{
    ApplicationArea = All;
    Caption = 'Project Invoice Projects';
    PageType = List;
    SourceTable = "TWE Proj. Inv. Project";
    UsageCategory = Lists;
    CardPageID = "TWE Proj. Inv. Project Card";
    InsertAllowed = false;
    ModifyAllowed = false;
    AdditionalSearchTerms = 'project,invoice,projects,tweecore,proj';

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
            action(GetProjects)
            {
                ApplicationArea = All;
                Caption = 'Import Projects';
                ToolTip = 'Imports all projects from project management systems.';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ProjInvImportMgt: Codeunit "TWE Proj. Inv. Import Mgt";
                begin
                    ProjInvImportMgt.RequestAllProjects();
                end;
            }
            action(GetHours)
            {
                ApplicationArea = All;
                Caption = 'Import Project Hours';
                ToolTip = 'Imports specified project hours from project management systems.';
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
}
