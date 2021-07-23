codeunit 70704952 "TWE Proj. Inv. Import Mgt"
{
    procedure GetProjectDataByDate(requestFromDate: Date; requestToDate: Date) success: Boolean
    var
        transactions: Dictionary of [Text[50], Text[50]];
    begin
        //TODO:Funktion anpassen
        /*
        if requestTransactionListByDate(requestFromDate, requestToDate, transactions) then
            if transactions.Count() > 0 then begin //TODO: else information nothing found
                if requestReceiptsByTransactionList(transactions) then
                    exit(true);
            end else begin
                Message(MsgNoTransactionsFoundLbl);
                exit(false);
            end;

        Error(ErrDataReceiveFailedLbl);
        */
    end;

    procedure TransferImportedData(ImportHeader: Record "TWE Proj. Inv. Import Header")
    var
        importLine: Record "TWE Proj. Inv. Import Line";
    begin
        importLine.SetRange("Import Header ID", ImportHeader."Entry No.");

        if importLine.FindSet() then
            repeat
            //TODO: Funktion ausprogrammieren
            until importLine.Next() = 0;
    end;
}