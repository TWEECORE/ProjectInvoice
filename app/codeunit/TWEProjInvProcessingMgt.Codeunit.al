/// <summary>
/// Codeunit TWE Proj. Inv. Processing Mgt (ID 70704953).
/// </summary>
codeunit 70704953 "TWE Proj. Inv. Processing Mgt"
{

    var
        ProjInvSetup: Record "TWE Proj. Inv. Setup";

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
                            project."Related to Customer No." := customer."No.";
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
                end;
                importLine.Imported := true;
                importLine.Modify();
            until importLine.Next() = 0;
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
        salesInvHeader: Record "Sales Invoice Header";
        salesInvLine: Record "Sales Invoice Line";
        projectHours: Record "TWE Proj. Inv. Project Hours";
        workDescriptionOutStream: OutStream;
        LineNo: Integer;
        projectLbl: Label 'Project: ';
        noUnprocessedProjectHoursLbl: Label 'There were no unprocessed work hours found for project %1', Comment = '%1=Project Name';
    begin
        repeat
            projectHours.SetRange("Project ID", Project.ID);
            projectHours.SetRange(Invoiced, false);
            if projectHours.FindSet() then begin
                salesInvHeader.Init();
                salesInvHeader."Document Date" := Today;
                salesInvHeader.Validate("Sell-to Customer No.", Project."Related to Customer No.");
                salesInvHeader.Validate("Bill-to Customer No.", Project."Related to Customer No.");
                salesInvHeader."Work Description".CreateOutStream(workDescriptionOutStream);
                workDescriptionOutStream.Write(projectLbl + Project.Name);
                salesInvHeader.Insert();
                LineNo := 0;

                repeat
                    salesInvLine.Init();
                    salesInvLine."Document No." := salesInvHeader."No.";
                    LineNo += 10000;
                    salesInvLine."Line No." := LineNo;
                    salesInvLine.Insert();

                    if Project."Invoice Type" = Project."Invoice Type"::" " then begin
                        ProjInvSetup.GetSetup();
                        case ProjInvSetup."Invoice Type" of
                            "TWE Proj. Inv. Invoice Type"::"G/L Account":
                                salesInvLine.Type := salesInvLine.Type::"G/L Account";
                            "TWE Proj. Inv. Invoice Type"::Item:
                                salesInvLine.Type := salesInvLine.Type::Item;
                            "TWE Proj. Inv. Invoice Type"::Resource:
                                salesInvLine.Type := salesInvLine.Type::Resource;
                        end;
                        salesInvLine."No." := ProjInvSetup."No.";
                    end else begin
                        case Project."Invoice Type" of
                            "TWE Proj. Inv. Invoice Type"::"G/L Account":
                                salesInvLine.Type := salesInvLine.Type::"G/L Account";
                            "TWE Proj. Inv. Invoice Type"::Item:
                                salesInvLine.Type := salesInvLine.Type::Item;
                            "TWE Proj. Inv. Invoice Type"::Resource:
                                salesInvLine.Type := salesInvLine.Type::Resource;
                        end;
                        salesInvLine."No." := Project."No.";
                    end;

                    salesInvLine.Description := CopyStr(projectHours."Work Description", 1, MaxStrLen(salesInvLine.Description));
                    salesInvLine."Description 2" := CopyStr(projectHours."Ticket ID" + ' ' + projectHours."Ticket Name", 1, MaxStrLen(salesInvLine."Description 2"));
                    salesInvLine.Amount := projectHours.Hours;
                    if Project."Use Standard Hourly Rate" then
                        salesInvLine."Unit Price" := Project."Standard Hourly Rate";
                    salesInvLine.Modify();

                until projectHours.Next() = 0;
                success := true;
            end else
                Message(noUnprocessedProjectHoursLbl, Project.Name);
        until Project.Next() = 0;
    end;
}