/// <summary>
/// Page TWE Proj. Inv. Imports (ID 70704952).
/// </summary>
page 70704952 "TWE Proj. Inv. Imports"
{
    PageType = list;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "TWE Proj. Inv. Import Header";
    Caption = 'Project Invoice Imports';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(EntryNo; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Import Header Entry No.';
                }
                field(NoOfEntries; Rec."No. of Entries")
                {
                    ApplicationArea = All;
                    ToolTip = 'Amount of all received import lines';
                }
                field(NoImportedEntries; Rec."No of imported Entries")
                {
                    ApplicationArea = All;
                    ToolTip = 'Amount of already imported import lines';
                }
                field(TotalHours; Rec."Total Hours")
                {
                    ApplicationArea = All;
                    ToolTip = 'Total amount of all imported hours';
                }
                field(ImportDate; Rec."Import Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Date the import was executed';
                }
                field(ImportTime; Rec."Import Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Time the import was executed';
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Defines whether all import lines were imported or not';
                }
                field("UserID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'User ID';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetProjMgtData)
            {
                ApplicationArea = All;
                Caption = 'Get Project Mgt. System Data';
                ToolTip = 'Imports project data from defined project management system';

                trigger OnAction()
                begin
                    Report.Run(Report::"TWE Proj. Inv. Import");
                end;
            }

            action(ImportProjectData)
            {
                ApplicationArea = All;
                Caption = 'Create BC Project Invoive Data';
                ToolTip = 'Creates imported Project Mgt. System data in Business Central';

                trigger OnAction()
                var
                    ProjInvProcessing: Codeunit "TWE Proj. Inv. Processing Mgt";
                begin
                    //Todo: Record abfiltern
                    ProjInvProcessing.TransferImportedData(Rec);
                end;
            }


        }
    }
}