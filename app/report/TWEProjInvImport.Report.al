/// <summary>
/// Report TWE SumUp Import (ID 90100).
/// </summary>
report 70704950 "TWE Proj. Inv. Import"
{
    ProcessingOnly = true;

    dataset
    {

    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Period)
                {
                    field(BeginDate; FromDate)
                    {
                        ApplicationArea = All;
                        Caption = 'From date';
                        ToolTip = 'Select a start date for the Project Hour import';
                    }
                    field(EndDate; ToDate)
                    {
                        ApplicationArea = All;
                        Caption = 'To date';
                        ToolTip = 'Select a start date for the Project Hour import';

                        trigger OnValidate()
                        begin
                            if ToDate < FromDate then
                                Error(ToDateBeforeFromDateLbl);
                        end;
                    }
                }
            }
        }

    }

    var
        FromDate: Date;
        ToDate: Date;
        ToDateBeforeFromDateLbl: Label 'The date value in field "to date" can not be a date before the "from date".';

    trigger OnInitReport()
    var
    begin
        FromDate := CalcDate('<-CM>', Today);
        ToDate := Today;
    end;

    trigger OnPreReport()
    var
        projInvImportMgt: Codeunit "TWE Proj. Inv. Import Mgt";
    begin
        projInvImportMgt.GetProjectDataByDate(FromDate, toDate);
    end;
}