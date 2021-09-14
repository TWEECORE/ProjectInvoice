/// <summary>
/// Report TWE SumUp Import (ID 90100).
/// </summary>
report 70704950 "TWE Proj. Inv. Import"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem(DataItemName; Integer)
        {
            DataItemTableView = where(Number = Const(1));
            trigger OnPostDataItem()
            var
                projInvImportMgt: Codeunit "TWE Proj. Inv. Import Mgt";

            begin
                projInvImportMgt.GetProjectDataByDate(FromDate, toDate);
            end;
        }
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
                        ToolTip = 'Select a start date for the SumUp import';
                    }
                    field(EndDate; ToDate)
                    {
                        ApplicationArea = All;
                        Caption = 'To date';
                        ToolTip = 'Select a start date for the SumUp import';

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
        ToDateBeforeFromDateLbl: Label 'The date value in field "to date" can not be a date before the "from date"';
}