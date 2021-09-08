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
    InsertAllowed = false;

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
                field(Processed; Rec.Imported)
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
                Caption = 'Import Project Data';
                ToolTip = 'Imports project data from defined project management system';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Report.Run(Report::"TWE Proj. Inv. Import");
                end;
            }
            action(OpenImportLines)
            {
                Caption = 'Open Import Lines';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Opens Import Lines for selected Import Entry';

                trigger OnAction()
                var
                    importHeader: Record "TWE Proj. Inv. Import Header";
                    importLine: Record "TWE Proj. Inv. Import Line";
                    importLinesPage: Page "TWE Proj. Inv. Import Lines";
                    errNoLinesLbl: Label 'There are no Lines for %1=%2', Comment = '%1=ImportHeaderIdCaption, %2=HeaderID';
                begin
                    CurrPage.SetSelectionFilter(importHeader);
                    if importHeader.FindSet() then;
                    importLine.SetRange("Import Header ID", importHeader."Entry No.");
                    if importLine.FindSet() then begin
                        importLinesPage.SetTableView(importLine);
                        importLinesPage.RunModal()
                    end else
                        Error(errNoLinesLbl, importLine.FieldCaption("Import Header ID"), importHeader."Entry No.");
                end;
            }

            action(ImportProjectData)
            {
                ApplicationArea = All;
                Caption = 'Apply Import Data';
                ToolTip = 'Creates imported Project Mgt. System data in Business Central';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    importHeader: Record "TWE Proj. Inv. Import Header";
                    ProjInvProcessing: Codeunit "TWE Proj. Inv. Processing Mgt";
                    noEntrySelectedErr: Label 'There was no entry selected.';
                begin
                    CurrPage.SetSelectionFilter(importHeader);
                    if importHeader.FindSet() then
                        ProjInvProcessing.TransferImportedData(importHeader)
                    else
                        Message(noEntrySelectedErr);
                end;
            }


        }
    }
}