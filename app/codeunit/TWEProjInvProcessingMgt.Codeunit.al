/// <summary>
/// Codeunit TWE Proj. Inv. Processing Mgt (ID 70704953).
/// </summary>
codeunit 70704953 "TWE Proj. Inv. Processing Mgt"
{
    var
        ProjInvSetup: Record "TWE Proj. Inv. Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        Reportselections: Record "Report Selections";
        ReportUsage: Enum "Report Selection Usage";
        NoSeriesMgt: Codeunit NoSeriesManagement;


    /// <summary>
    /// TransferImportedData.
    /// </summary>
    /// <param name="ImportHeader">Record "TWE Proj. Inv. Import Header".</param>
    /// <returns>Return variable success of type Boolean.</returns>
    procedure TransferImportedData(ImportHeader: Record "TWE Proj. Inv. Import Header") success: Boolean
    var
        importLine: Record "TWE Proj. Inv. Import Line";
        project: Record "TWE Proj. Inv. Project";
        ticket: Record "TWE Proj. Inv. Ticket";
        projectHour: Record "TWE Proj. Inv. Project Hours";
        customer: Record Customer;
        noLinesToImportLbl: Label 'There is no new data to import for Import Header = %1', Comment = '%1=Import Header';
        AllImportedLbl: Label 'The project management data was successfully imported';
    begin
        ProjInvSetup.GetSetup();
        importLine.SetRange("Import Header ID", ImportHeader."Entry No.");
        importLine.SetRange(Imported, false);
        if importLine.FindSet() then begin
            repeat
                if not project.Get(importLine."Project ID") then begin
                    project.Init();
                    project.ID := CopyStr(importLine."Project ID", 1, MaxStrLen(project.ID));
                    project.Name := importLine."Project Name";
                    project."Project Mgt System" := importLine."Project Mgt. System";
                    project."Summarize Times for Invoice" := ProjInvSetup."Summarize Times for Invoice";
                    project."Summarized Description" := ProjInvSetup."Summarized Description";

                    customer.SetRange(Name, importLine."Project Name");
                    if customer.FindSet() then
                        if customer.Count = 1 then
                            project.Validate("Related to Customer No.", customer."No.");
                    project.Insert();
                end;
                if not ticket.Get(importLine."Ticket No.") then begin
                    ticket.Init();
                    ticket."No." := importLine."Ticket No.";
                    ticket."Project ID" := importLine."Project ID";
                    ticket."Ticket Name" := importLine."Ticket Name";
                    ticket."Created At" := importLine."Ticket Created at";
                    ticket."Created from" := importLine."Ticket Creator";
                    ticket."Project Mgt. System" := importLine."Project Mgt. System";
                    ticket.Insert();
                end;

                if not projectHour.Get(importLine."WorkItem ID") then begin
                    projectHour.Init();
                    projectHour.ID := importLine."WorkItem ID";
                    projectHour."Project ID" := importLine."Project ID";
                    projectHour."Ticket ID" := importLine."Ticket No.";
                    projectHour."Ticket Name" := importLine."Ticket Name";
                    projectHour."Work Description" := importLine."WorkItem Description";
                    projectHour."Working Date" := importLine."WorkItem Created at";
                    projectHour.Hours := importLine.Hours;
                    projectHour."Hours to Invoice" := importLine.Hours;
                    projectHour.Agent := importLine.Agent;
                    projectHour.Insert();

                    if project.Get(projectHour."Project ID") then
                        if project."All Hours invoiced" then begin
                            project."All Hours invoiced" := false;
                            project.Modify();
                        end;
                end;
                importLine.Imported := true;
                importLine.Modify();
            until importLine.Next() = 0;
            ImportHeader.Imported := true;
            ImportHeader.Modify();
            Message(AllImportedLbl);
            success := true;
        end else
            Message(noLinesToImportLbl, ImportHeader."Entry No.");
    end;

    /// <summary>
    /// InvoiceCustomerUnprocessedProjectHours.
    /// </summary>
    /// <param name="Customer">Record Customer.</param>
    procedure InvoiceCustomerUnprocessedProjectHours(Customer: Record Customer)
    var
        project: Record "TWE Proj. Inv. Project";
        noProjectsFoundLbl: Label 'No projects found for customer: "%1"', Comment = '%1=Customer Name';
    begin
        ProjInvSetup.GetSetup();
        project.SetRange("Related to Customer No.", Customer."No.");
        if project.FindSet() then
            InvoiceProject(project)
        else
            Message(noProjectsFoundLbl, Customer.Name);
    end;

    /// <summary>
    /// InvoiceUnprocessedProjectHours.
    /// </summary>
    /// <param name="Project">Record "TWE Proj. Inv. Project".</param>
    /// <returns>Return variable success of type Boolean.</returns>
    procedure InvoiceProject(Project: Record "TWE Proj. Inv. Project") success: Boolean
    var
        salesHeader: Record "Sales Header";
        salesLine: Record "Sales Line";
        projectHours: Record "TWE Proj. Inv. Project Hours";
        workDescriptionOutStream: OutStream;
        LineNo: Integer;
        FirstLine: Boolean;
        projectLbl: Label 'Project: ';
        noUnprocessedProjectHoursLbl: Label 'There were no unprocessed work hours found for project %1', Comment = '%1=Project Name';
        invoicesCreatedLbl: Label '%1 invoices created', Comment = '%1=NAmount of Invoices';
    begin
        ProjInvSetup.GetSetup();
        SalesSetup.Get();

        FirstLine := true;
        projectHours.SetRange("Project ID", Project.ID);
        projectHours.SetRange(Invoiced, false);
        if projectHours.FindSet() then begin
            salesHeader.Init();
            salesHeader."Document Type" := salesHeader."Document Type"::Invoice;
            if ProjInvSetup."No. Series for Proj. Invoices" <> '' then
                salesHeader."No." := NoSeriesMgt.GetNextNo(ProjInvSetup."No. Series for Proj. Invoices", WorkDate(), true)
            else
                salesHeader."No." := NoSeriesMgt.GetNextNo(SalesSetup."Invoice Nos.", WorkDate(), true);
            salesHeader.Insert();

            salesHeader."Document Date" := Today;
            salesHeader.Validate("Sell-to Customer No.", Project."Related to Customer No.");
            salesHeader.Validate("Bill-to Customer No.", Project."Related to Customer No.");
            salesHeader."Work Description".CreateOutStream(workDescriptionOutStream);
            workDescriptionOutStream.Write(projectLbl + Project.Name);
            salesHeader.Modify();
            LineNo := 0;

            repeat
                if Project."Summarize Times for Invoice" then
                    if FirstLine = true then begin
                        salesLine.Init();
                        salesLine."Document No." := salesHeader."No.";
                        salesLine."Document Type" := salesHeader."Document Type";
                        LineNo += 10000;
                        salesLine."Line No." := LineNo;
                        salesLine.Insert();

                        salesLine.Description := Project."Summarized Description";

                        if Project."Use Standard Hourly Rate" then
                            salesLine."Unit Price" := Project."Standard Hourly Rate";

                        projectHours."Target Invoice" := salesLine."Document No.";
                        salesLine.Quantity := projectHours."Hours to Invoice";
                        salesLine.Modify();

                        projectHours.Invoiced := true;
                        projectHours.Modify();
                        FirstLine := false;
                    end else begin
                        salesLine.Quantity += projectHours."Hours to Invoice";
                        salesLine.Modify();

                        projectHours."Target Invoice" := salesLine."Document No.";
                        projectHours.Invoiced := true;
                        projectHours.Modify();
                    end
                else begin
                    salesLine.Init();
                    salesLine."Document No." := salesHeader."No.";
                    salesLine."Document Type" := salesHeader."Document Type";
                    LineNo += 10000;
                    salesLine."Line No." := LineNo;
                    salesLine.Insert();
                    if Project."Invoice Type" = Project."Invoice Type"::" " then begin
                        ProjInvSetup.Get();
                        case ProjInvSetup."Invoice Type" of
                            "TWE Proj. Inv. Invoice Type"::"G/L Account":
                                salesLine.Type := salesLine.Type::"G/L Account";
                            "TWE Proj. Inv. Invoice Type"::Item:
                                salesLine.Type := salesLine.Type::Item;
                            "TWE Proj. Inv. Invoice Type"::Resource:
                                salesLine.Type := salesLine.Type::Resource;
                        end;
                        salesLine."No." := ProjInvSetup."No.";
                    end else begin
                        case Project."Invoice Type" of
                            "TWE Proj. Inv. Invoice Type"::"G/L Account":
                                salesLine.Type := salesLine.Type::"G/L Account";
                            "TWE Proj. Inv. Invoice Type"::Item:
                                salesLine.Type := salesLine.Type::Item;
                            "TWE Proj. Inv. Invoice Type"::Resource:
                                salesLine.Type := salesLine.Type::Resource;
                        end;
                        salesLine."No." := Project."No.";
                    end;

                    salesLine.Description := CopyStr(projectHours."Work Description", 1, MaxStrLen(salesLine.Description));
                    salesLine."Description 2" := CopyStr(projectHours."Ticket ID" + ' ' + projectHours."Ticket Name", 1, MaxStrLen(salesLine."Description 2"));
                    salesLine.Quantity := projectHours."Hours to Invoice";
                    if Project."Use Standard Hourly Rate" then
                        salesLine."Unit Price" := Project."Standard Hourly Rate";
                    salesLine.Modify();

                    projectHours."Target Invoice" := salesLine."Document No.";
                    projectHours.Invoiced := true;
                    projectHours.Modify();
                end;

            until projectHours.Next() = 0;
            success := true;
            projectHours.SetRange("Project ID", Project.ID);
            projectHours.SetRange(Invoiced, false);

            ReportSelections.SaveAsDocumentAttachment(ReportUsage::"TWE PI Project Hours".AsInteger(), projectHours, SalesHeader."No.",
                                                    SalesHeader."Sell-to Customer No.", true);
            Message(invoicesCreatedLbl, Format(1));
        end else
            Message(noUnprocessedProjectHoursLbl, Project.Name);
    end;

    procedure InvoiceMultipleProjects(Project: Record "TWE Proj. Inv. Project") success: Boolean
    var
        salesHeader: Record "Sales Header";
        salesLine: Record "Sales Line";
        projectHours: Record "TWE Proj. Inv. Project Hours";
        workDescriptionOutStream: OutStream;
        LineNo: Integer;
        counter: integer;
        FirstLine: Boolean;
        projectLbl: Label 'Project: ';
        noUnprocessedProjectHoursLbl: Label 'There were no unprocessed work hours found for project %1', Comment = '%1=Project Name';
        invoicesCreatedLbl: Label '%1 invoices created', Comment = '%1=NAmount of Invoices';
    begin
        ProjInvSetup.GetSetup();
        SalesSetup.Get();
        counter := 0;
        repeat
            projectHours.SetRange("Project ID", Project.ID);
            projectHours.SetRange(Invoiced, false);
            if projectHours.FindSet() then begin
                salesHeader.Init();
                salesHeader."Document Type" := salesHeader."Document Type"::Invoice;
                if ProjInvSetup."No. Series for Proj. Invoices" <> '' then
                    salesHeader."No." := NoSeriesMgt.GetNextNo(ProjInvSetup."No. Series for Proj. Invoices", WorkDate(), true)
                else
                    salesHeader."No." := NoSeriesMgt.GetNextNo(SalesSetup."Invoice Nos.", WorkDate(), true);
                salesHeader.Insert();

                salesHeader."Document Date" := Today;
                salesHeader.Validate("Sell-to Customer No.", Project."Related to Customer No.");
                salesHeader.Validate("Bill-to Customer No.", Project."Related to Customer No.");
                salesHeader."Work Description".CreateOutStream(workDescriptionOutStream);
                workDescriptionOutStream.Write(projectLbl + Project.Name);
                salesHeader.Modify();
                LineNo := 0;

                repeat
                    if Project."Summarize Times for Invoice" then
                        if FirstLine = true then begin
                            salesLine.Init();
                            salesLine."Document No." := salesHeader."No.";
                            salesLine."Document Type" := salesHeader."Document Type";
                            LineNo += 10000;
                            salesLine."Line No." := LineNo;
                            salesLine.Insert();

                            salesLine.Description := Project."Summarized Description";

                            if Project."Use Standard Hourly Rate" then
                                salesLine."Unit Price" := Project."Standard Hourly Rate";

                            salesLine.Quantity := projectHours."Hours to Invoice";
                            salesLine.Modify();

                            projectHours."Target Invoice" := salesLine."Document No.";
                            projectHours.Invoiced := true;
                            projectHours.Modify();
                            FirstLine := false;
                        end else begin
                            salesLine.Quantity += projectHours."Hours to Invoice";
                            salesLine.Modify();

                            projectHours."Target Invoice" := salesLine."Document No.";
                            projectHours.Invoiced := true;
                            projectHours.Modify();
                        end
                    else begin
                        salesLine.Init();
                        salesLine."Document No." := salesHeader."No.";
                        salesLine."Document Type" := salesHeader."Document Type";
                        LineNo += 10000;
                        salesLine."Line No." := LineNo;
                        salesLine.Insert();

                        if Project."Invoice Type" = Project."Invoice Type"::" " then begin
                            ProjInvSetup.Get();
                            case ProjInvSetup."Invoice Type" of
                                "TWE Proj. Inv. Invoice Type"::"G/L Account":
                                    salesLine.Type := salesLine.Type::"G/L Account";
                                "TWE Proj. Inv. Invoice Type"::Item:
                                    salesLine.Type := salesLine.Type::Item;
                                "TWE Proj. Inv. Invoice Type"::Resource:
                                    salesLine.Type := salesLine.Type::Resource;
                            end;
                            salesLine."No." := ProjInvSetup."No.";
                        end else begin
                            case Project."Invoice Type" of
                                "TWE Proj. Inv. Invoice Type"::"G/L Account":
                                    salesLine.Type := salesLine.Type::"G/L Account";
                                "TWE Proj. Inv. Invoice Type"::Item:
                                    salesLine.Type := salesLine.Type::Item;
                                "TWE Proj. Inv. Invoice Type"::Resource:
                                    salesLine.Type := salesLine.Type::Resource;
                            end;
                            salesLine."No." := Project."No.";
                        end;

                        salesLine.Description := CopyStr(projectHours."Work Description", 1, MaxStrLen(salesLine.Description));
                        salesLine."Description 2" := CopyStr(projectHours."Ticket ID" + ' ' + projectHours."Ticket Name", 1, MaxStrLen(salesLine."Description 2"));
                        salesLine.Amount := projectHours."Hours to Invoice";
                        if Project."Use Standard Hourly Rate" then
                            salesLine."Unit Price" := Project."Standard Hourly Rate";
                        salesLine.Modify();

                        projectHours."Target Invoice" := salesLine."Document No.";
                        projectHours.Invoiced := true;
                        projectHours.Modify();
                    end;
                until projectHours.Next() = 0;

                counter += 1;
                success := true;
            end else
                Message(noUnprocessedProjectHoursLbl, Project.Name);
        until Project.Next() = 0;

        Message(invoicesCreatedLbl, counter);
    end;

    procedure InvoiceProjectHours(var ProjectHour: Record "TWE Proj. Inv. Project Hours")
    var
        salesHeader: Record "Sales Header";
        salesLine: Record "Sales Line";
        project: Record "TWE Proj. Inv. Project";
        workDescriptionOutStream: OutStream;
        LineNo: Integer;
        counter: integer;
        FirstLine: Boolean;
        projectLbl: Label 'Project: ';
        invoicesCreatedLbl: Label '%1 invoices created', Comment = '%1=NAmount of Invoices';
    begin
        ProjInvSetup.GetSetup();
        SalesSetup.Get();
        FirstLine := true;

        if project.Get(ProjectHour."Project ID") then;

        counter := 0;

        salesHeader.Init();
        if ProjInvSetup."No. Series for Proj. Invoices" <> '' then
            salesHeader."No." := NoSeriesMgt.GetNextNo(ProjInvSetup."No. Series for Proj. Invoices", WorkDate(), true)
        else
            salesHeader."No." := NoSeriesMgt.GetNextNo(SalesSetup."Invoice Nos.", WorkDate(), true);
        salesHeader."Document Type" := salesHeader."Document Type"::Invoice;
        salesHeader.Insert();

        salesHeader."Document Date" := Today;
        salesHeader.Validate("Sell-to Customer No.", project."Related to Customer No.");
        salesHeader.Validate("Bill-to Customer No.", project."Related to Customer No.");
        salesHeader."Work Description".CreateOutStream(workDescriptionOutStream);
        workDescriptionOutStream.Write(projectLbl + project.Name);
        salesHeader.Modify();
        LineNo := 0;

        repeat
            if project."Summarize Times for Invoice" then
                if FirstLine = true then begin
                    salesLine.Init();
                    salesLine."Document No." := salesHeader."No.";
                    salesLine."Document Type" := salesHeader."Document Type";
                    LineNo += 10000;
                    salesLine."Line No." := LineNo;
                    salesLine.Insert();

                    salesLine.Description := project."Summarized Description";

                    if Project."Use Standard Hourly Rate" then
                        salesLine."Unit Price" := project."Standard Hourly Rate";

                    salesLine.Quantity := ProjectHour."Hours to Invoice";
                    salesLine.Modify();

                    ProjectHour."Target Invoice" := salesLine."Document No.";
                    ProjectHour.Invoiced := true;
                    ProjectHour.Modify();
                    FirstLine := false;
                end else begin
                    salesLine.Quantity += ProjectHour."Hours to Invoice";
                    salesLine.Modify();

                    ProjectHour."Target Invoice" := salesLine."Document No.";
                    ProjectHour.Invoiced := true;
                    ProjectHour.Modify();
                end
            else begin
                salesLine.Init();
                salesLine."Document No." := salesHeader."No.";
                salesLine."Document Type" := salesHeader."Document Type";
                LineNo += 10000;
                salesLine."Line No." := LineNo;
                salesLine.Insert();

                if Project."Invoice Type" = Project."Invoice Type"::" " then begin
                    ProjInvSetup.Get();
                    case ProjInvSetup."Invoice Type" of
                        "TWE Proj. Inv. Invoice Type"::"G/L Account":
                            salesLine.Type := salesLine.Type::"G/L Account";
                        "TWE Proj. Inv. Invoice Type"::Item:
                            salesLine.Type := salesLine.Type::Item;
                        "TWE Proj. Inv. Invoice Type"::Resource:
                            salesLine.Type := salesLine.Type::Resource;
                    end;
                    salesLine."No." := ProjInvSetup."No.";
                end else begin
                    case Project."Invoice Type" of
                        "TWE Proj. Inv. Invoice Type"::"G/L Account":
                            salesLine.Type := salesLine.Type::"G/L Account";
                        "TWE Proj. Inv. Invoice Type"::Item:
                            salesLine.Type := salesLine.Type::Item;
                        "TWE Proj. Inv. Invoice Type"::Resource:
                            salesLine.Type := salesLine.Type::Resource;
                    end;
                    salesLine."No." := Project."No.";
                end;

                salesLine.Description := CopyStr(ProjectHour."Work Description", 1, MaxStrLen(salesLine.Description));
                salesLine."Description 2" := CopyStr(ProjectHour."Ticket ID" + ' ' + ProjectHour."Ticket Name", 1, MaxStrLen(salesLine."Description 2"));
                salesLine.Amount := ProjectHour."Hours to Invoice";
                if project."Use Standard Hourly Rate" then
                    salesLine."Unit Price" := project."Standard Hourly Rate";
                salesLine.Modify();

                ProjectHour."Target Invoice" := salesLine."Document No.";
                ProjectHour.Invoiced := true;
                ProjectHour.Modify();
            end;
        until ProjectHour.Next() = 0;
        
        ReportSelections.SaveAsDocumentAttachment(ReportUsage::"TWE PI Project Hours".AsInteger(), ProjectHour, SalesHeader."No.",
                                                SalesHeader."Sell-to Customer No.", true);

        Message(invoicesCreatedLbl, counter);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnAfterInitFieldsFromRecRef', '', true, true)]
    local procedure OnAfterInitFieldsFromRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        fRef: FieldRef;
        docNo: Code[20];
    begin
        if recRef.Number = 70704956 then begin
            fRef := recRef.Field(21);
            docNo := fRef.Value;
            DocumentAttachment.Validate("Table ID", 36);
            DocumentAttachment.Validate("Document Type", Enum::"Attachment Document Type"::Invoice);
            DocumentAttachment.Validate("No.", docNo);
        end;
    end;

    procedure convertUmlaute(String: Text[150]) ConvertedString: text[150]
    var
        littleAELbl: Label 'Žñ';
        bigAELbl: Label 'Žä';
        littleUELbl: Label 'Ž‰';
        bigUELbl: Label 'Ž£';
        littleOELbl: Label 'ŽÂ';
        bigOELbl: Label 'Žû';
        sZLbl: Label 'Žƒ';
    begin
        ConvertedString := String;

        ConvertedString := replaceString(ConvertedString, littleAELbl, 'ä');
        ConvertedString := replaceString(ConvertedString, bigAELbl, 'Ä');
        ConvertedString := replaceString(ConvertedString, littleUELbl, 'ü');
        ConvertedString := replaceString(ConvertedString, bigUELbl, 'Ü');
        ConvertedString := replaceString(ConvertedString, littleOELbl, 'ö');
        ConvertedString := replaceString(ConvertedString, bigOELbl, 'Ö');
        ConvertedString := replaceString(ConvertedString, sZLbl, 'ß');
    end;

    local procedure replaceString(String: Text[150]; FindWhat: Text[150]; ReplaceWith: Text[150]) NewString: Text[150]
    begin
        WHILE STRPOS(String, FindWhat) > 0 DO
            String := DELSTR(String, STRPOS(String, FindWhat)) + ReplaceWith + COPYSTR(String, STRPOS(String, FindWhat) + STRLEN(FindWhat));
        NewString := String;
    end;

    /// <summary>
    /// getDateFromUnixTimeStamp.
    /// </summary>
    /// <param name="unixTime">Text.</param>
    /// <returns>Return value of type Date.</returns>
    procedure getDateFromUnixTimeStamp(unixTime: Text): Date
    var
        unixTimeInt: Integer;
        unixStartDate: Date;
        noOfDays: Integer;
        endDate: Date;
    begin
        unixTime := DelStr(unixTime, 11);
        Evaluate(unixTimeInt, unixTime);
        unixStartDate := 19700101D;
        NoOfDays := unixTimeInt DIV 86400;

        endDate := unixStartDate + NoOfDays;

        Exit(endDate);
    end;

    procedure getUnixTimeStampFromDate(DateValue: Date): Integer
    var
        unixStartDate: Date;
        noOfDays: Integer;
    begin
        unixStartDate := 19700101D;
        noOfDays := DateValue - unixStartDate;

        exit(noOfDays * 86400);
    end;

    procedure DateToText(DateToConvert: Date) DateText: text
    var
        year: integer;
        month: integer;
        day: integer;
        yearText: Text;
        monthText: Text;
        dayText: Text;
    begin
        year := DATE2DMY(DateToConvert, 3);
        month := DATE2DMY(DateToConvert, 2);
        day := DATE2DMY(DateToConvert, 1);

        if day < 10 then
            dayText := '0' + Format(day)
        else
            dayText := Format(day);

        if month < 10 then
            monthText := '0' + Format(month)
        else
            monthText := Format(month);

        yearText := Format(year);

        DateText := yearText + '-' + monthText + '-' + dayText;
    end;
}