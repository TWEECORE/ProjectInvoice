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
                projInvImportMgt.GetProjectMgtSystemDataByDate(FromDate, Today);
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
                }
            }
        }

    }

    var
        FromDate: Date;
}