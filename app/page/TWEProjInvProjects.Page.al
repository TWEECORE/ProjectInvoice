/// <summary>
/// Page TWE Proj. Inv. Projects (ID 70704954).
/// </summary>
page 70704954 "TWE Proj. Inv. Projects"
{
    ApplicationArea = All;
    Caption = 'Project Invoice Projects';
    PageType = List;
    SourceTable = "TWE Proj. Inv. Project";
    UsageCategory = Lists;
    CardPageID = "TWE Proj. Inv. Project Card";
    InsertAllowed = false;
    ModifyAllowed = false;
    AdditionalSearchTerms = 'project,invoice,projects,tweecore';

    layout
    {
        area(content)
        {
            repeater(General)
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
                ToolTip = 'Imports projects from project management systems';
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
                ToolTip = 'Imports project hours from project management systems';
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
