/// <summary>
/// Codeunit TWE Proj. Inv. Processing Mgt (ID 70704953).
/// </summary>
codeunit 70704953 "TWE Proj. Inv. Processing Mgt"
{

    var
        ProjInvSetup: Record "TWE Proj. Inv. Setup";
        SalesSetup: Record "Sales & Receivables Setup";
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
        importLine.SetRange("Import Header ID", ImportHeader."Entry No.");
        importLine.SetRange(Imported, false);
        if importLine.FindSet() then begin
            repeat
                if not project.Get(importLine."Project ID") then begin
                    project.Init();
                    project.ID := CopyStr(importLine."Project ID", 1, MaxStrLen(project.ID));
                    project.Name := importLine."Project Name";
                    project."Project Mgt System" := importLine."Project Mgt. System";

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
                    ticket.Insert();
                end;

                if not projectHour.Get(importLine."WorkItem ID") then begin
                    projectHour.Init();
                    projectHour.ID := importLine."WorkItem ID";
                    projectHour."Project ID" := importLine."Project ID";
                    projectHour."Ticket ID" := importLine."Ticket No.";
                    projectHour."Ticket Name" := importLine."Ticket Name";
                    projectHour."Work Description" := importLine."WorkItem Description";
                    projectHour.Hours := importLine.Hours;
                    projectHour.Agent := importLine.Agent;
                    projectHour.Insert();
                end;
                importLine.Imported := true;
                importLine.Modify();
            until importLine.Next() = 0;
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
        project.SetRange("Related to Customer No.", Customer."No.");
        if project.FindSet() then
            InvoiceUnprocessedProjectHours(project)
        else
            Message(noProjectsFoundLbl, Customer.Name);
    end;

    /// <summary>
    /// InvoiceUnprocessedProjectHours.
    /// </summary>
    /// <param name="Project">Record "TWE Proj. Inv. Project".</param>
    /// <returns>Return variable success of type Boolean.</returns>
    procedure InvoiceUnprocessedProjectHours(Project: Record "TWE Proj. Inv. Project") success: Boolean
    var
        salesHeader: Record "Sales Header";
        salesLine: Record "Sales Line";
        projectHours: Record "TWE Proj. Inv. Project Hours";
        workDescriptionOutStream: OutStream;
        LineNo: Integer;
        projectLbl: Label 'Project: ';
        noUnprocessedProjectHoursLbl: Label 'There were no unprocessed work hours found for project %1', Comment = '%1=Project Name';
        invoicesCreatedLbl: Label '%1 invoices created', Comment = '%1=NAmount of Invoices';
    begin
        SalesSetup.Get();
        projectHours.SetRange("Project ID", Project.ID);
        projectHours.SetRange(Invoiced, false);
        if projectHours.FindSet() then begin
            salesHeader.Init();
            salesHeader."Document Type" := salesHeader."Document Type"::Invoice;
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
                salesLine.Init();
                salesLine."Document No." := salesHeader."No.";
                salesLine."Document Type" := salesHeader."Document Type";
                LineNo += 10000;
                salesLine."Line No." := LineNo;
                salesLine.Insert();

                if Project."Invoice Type" = Project."Invoice Type"::" " then begin
                    ProjInvSetup.GetSetup();
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
                salesLine.Quantity := projectHours.Hours;
                if Project."Use Standard Hourly Rate" then
                    salesLine."Unit Price" := Project."Standard Hourly Rate";
                salesLine.Modify();

            until projectHours.Next() = 0;
            success := true;
        end else
            Message(noUnprocessedProjectHoursLbl, Project.Name);


        Message(invoicesCreatedLbl, Format(1));
    end;

    procedure InvoiceUnprocessedProjectHoursCustomer(Project: Record "TWE Proj. Inv. Project") success: Boolean
    var
        salesHeader: Record "Sales Header";
        salesLine: Record "Sales Line";
        projectHours: Record "TWE Proj. Inv. Project Hours";
        workDescriptionOutStream: OutStream;
        LineNo: Integer;
        counter: integer;
        projectLbl: Label 'Project: ';
        noUnprocessedProjectHoursLbl: Label 'There were no unprocessed work hours found for project %1', Comment = '%1=Project Name';
        invoicesCreatedLbl: Label '%1 invoices created', Comment = '%1=NAmount of Invoices';
    begin
        counter := 0;
        repeat
            projectHours.SetRange("Project ID", Project.ID);
            projectHours.SetRange(Invoiced, false);
            if projectHours.FindSet() then begin
                salesHeader.Init();
                salesHeader."Document Date" := Today;
                salesHeader."Document Type" := salesHeader."Document Type"::Invoice;
                salesHeader.Validate("Sell-to Customer No.", Project."Related to Customer No.");
                salesHeader.Validate("Bill-to Customer No.", Project."Related to Customer No.");
                salesHeader."Work Description".CreateOutStream(workDescriptionOutStream);
                workDescriptionOutStream.Write(projectLbl + Project.Name);
                salesHeader.Insert();
                LineNo := 0;

                repeat
                    salesLine.Init();
                    salesLine."Document No." := salesHeader."No.";
                    salesLine."Document Type" := salesHeader."Document Type";
                    LineNo += 10000;
                    salesLine."Line No." := LineNo;
                    salesLine.Insert();

                    if Project."Invoice Type" = Project."Invoice Type"::" " then begin
                        ProjInvSetup.GetSetup();
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
                    salesLine.Amount := projectHours.Hours;
                    if Project."Use Standard Hourly Rate" then
                        salesLine."Unit Price" := Project."Standard Hourly Rate";
                    salesLine.Modify();

                until projectHours.Next() = 0;

                counter += 1;
                success := true;
            end else
                Message(noUnprocessedProjectHoursLbl, Project.Name);
        until Project.Next() = 0;

        Message(invoicesCreatedLbl, counter);
    end;
}