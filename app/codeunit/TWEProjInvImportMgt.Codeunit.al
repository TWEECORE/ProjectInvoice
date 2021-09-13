/// <summary>
/// Codeunit TWE Proj. Inv. Import Mgt (ID 70704952).
/// </summary>
codeunit 70704952 "TWE Proj. Inv. Import Mgt"
{
    var
        ImportHeader: Record "TWE Proj. Inv. Import Header";
        BaseMgt: Codeunit "TWE Base Mgt";
        ImportItemArray: JsonArray;
        FromDate: Date;
        ToDate: Date;
        ErrDataReceiveFailedLbl: Label 'Could not receive data.';
        MsgNoProjectDataFoundLbl: Label 'No new project data available.';
        YoutrackWorkitemArgumentsLbl: Label '/youtrack/api/workItems?fields=$type,id,author($type,login),issue($type,idReadable,summary,created,project($type,shortName,name),reporter($type,login)),date,text,duration($type,minutes)&$skip=0&$top=10000';
        YoutrackProjectArgumentsLbl: Label '/youtrack/api/projects?fields=$type,shortName, name&$skip=0&$top=10000';
        //jiraWorkLogArgumentsLbl: Label '/rest/api/2/issue/BGHU-159/worklog';///worklog/updated?since=';
        JiraWorkLogArgumentsLbl: Label '/rest/tempo-timesheets/4/worklogs/search?from=2020-01-01';
        JiraProjectArgumentsLbl: Label '/rest/api/2/project';
        NoDataToImportLbl: Label 'There is no new project data to import';

        FirstLine: Boolean;


    /// <summary>
    /// GetProjectDataByDate.
    /// </summary>
    /// <param name="requestFromDate">Date.</param>
    /// <param name="requestToDate">Date.</param>
    procedure GetProjectDataByDate(requestFromDate: Date; requestToDate: Date)
    begin
        FromDate := requestFromDate;
        ToDate := requestToDate;
        if not requestProjectData() then
            Error(MsgNoProjectDataFoundLbl);
    end;

    /// <summary>
    /// RequestAllProjects.
    /// </summary>
    /// <returns>Return variable success of type Boolean.</returns>
    procedure RequestAllProjects() success: Boolean
    var
        oAuthApp: Record "TWE OAuth 2.0 Application";
    begin
        success := false;

        oAuthApp.SetRange("TWE Use Project Mgt. System", true);
        if oAuthApp.Find() then
            repeat
                if oAuthApp."TWE Project Mgt. System" = oAuthApp."TWE Project Mgt. System"::YoutTrack then
                    requestData(oAuthApp."TWE Project Mgt. System", YoutrackProjectArgumentsLbl, oAuthApp."TWE Use Permanent Token")
                else
                    requestData(oAuthApp."TWE Project Mgt. System", JiraProjectArgumentsLbl, oAuthApp."TWE Use Permanent Token");
                importProjects(oAuthApp);
            until oAuthApp.Next() = 0;
        success := true;
    end;

    local procedure importProjects(oAuthApp: Record "TWE OAuth 2.0 Application")
    var
        ProjInvProject: Record "TWE Proj. Inv. Project";
        jsonMethods: Codeunit "TWE JSONMethods";
        workItemObject: JsonObject;
        jToken: JsonToken;
    begin
        foreach jToken in ImportItemArray do begin
            workItemObject := jToken.AsObject();
            jsonMethods.SetJsonObject(workItemObject);
            ProjInvProject.Init();
            ProjInvProject.PopulateFromJson(workItemObject, oAuthApp."TWE Project Mgt. System");
            ProjInvProject.Insert();
        end;
    end;

    local procedure requestProjectData() success: Boolean
    var
        oAuthApp: Record "TWE OAuth 2.0 Application";
        importLine: Record "TWE Proj. Inv. Import Line";
    begin
        success := false;

        oAuthApp.SetRange("TWE Use Project Mgt. System", true);
        if oAuthApp.FindSet() then begin
            repeat
                createImportHeader(ImportHeader);

                case oAuthApp."TWE Project Mgt. System" of
                    "TWE Project Mgt. System"::YoutTrack:
                        requestData(oAuthApp."TWE Project Mgt. System", YoutrackWorkitemArgumentsLbl, oAuthApp."TWE Use Permanent Token");
                    "TWE Project Mgt. System"::"JIRA Tempo":
                        requestData(oAuthApp."TWE Project Mgt. System", JiraWorkLogArgumentsLbl, oAuthApp."TWE Use Permanent Token");
                end;

                createImportData(ImportItemArray, oAuthApp."TWE Project Mgt. System");
            until oAuthApp.Next() = 0;

            importline.SetRange("Import Header ID", ImportHeader."Entry No.");
            if importLine.IsEmpty() then begin
                Message(NoDataToImportLbl);
                ImportHeader.Delete();
            end;
        end;
        success := true;
    end;

    local procedure requestData(ProjMgtSystem: Enum "TWE Project Mgt. System"; RequestString: Text; UsePermToken: Boolean) success: Boolean
    var
        tempArguments: Record "TWE RESTWebServiceArguments" temporary;
    begin
        success := false;
        if not UsePermToken then
            tempArguments.RestMethod := tempArguments.RestMethod::get;

        case ProjMgtSystem of
            ProjMgtSystem::YoutTrack:
                begin
                    initArguments(tempArguments, RequestString, ProjMgtSystem::YoutTrack, UsePermToken);

                    if not callWebService(tempArguments, ProjMgtSystem::YoutTrack) then
                        Error('%1\\%2', ErrDataReceiveFailedLbl, tempArguments.GetResponseContentAsText());
                end;
            ProjMgtSystem::"JIRA Tempo":
                begin
                    initArguments(tempArguments, RequestString, ProjMgtSystem::"JIRA Tempo", UsePermToken);

                    if not callWebService(tempArguments, ProjMgtSystem::"JIRA Tempo") then
                        Error('%1\\%2', ErrDataReceiveFailedLbl, tempArguments.GetResponseContentAsText());
                end;
        end;

        success := ImportItemArray.ReadFrom(tempArguments.GetResponseContentAsText());
    end;

    local procedure createImportData(WorkitemArray: JsonArray; ProjMgtSystem: Enum "TWE Project Mgt. System") success: Boolean
    var
        jsonMethods: Codeunit "TWE JSONMethods";
        workItemObject: JsonObject;
        jToken: JsonToken;
    begin
        success := false;
        FirstLine := false;

        case ProjMgtSystem of
            ProjMgtSystem::YoutTrack:
                foreach jToken in WorkitemArray do begin
                    workItemObject := jToken.AsObject();
                    jsonMethods.SetJsonObject(workItemObject);
                    createImportLinesYoutrack(workItemObject, FromDate, ToDate);
                end;
            ProjMgtSystem::"JIRA Tempo":
                foreach jToken in WorkitemArray do begin
                    workItemObject := jToken.AsObject();
                    jsonMethods.SetJsonObject(workItemObject);
                    createImportLinesJIRA(workItemObject);
                end;
        end;
        success := true;
    end;

    local procedure createImportHeader(ImportHeader: Record "TWE Proj. Inv. Import Header") success: Boolean
    begin
        ImportHeader.Init();
        ImportHeader."Entry No." := importHeader.GetLastEntryNo() + 1;
        ImportHeader.Insert();

        ImportHeader."Import Date" := Today;
        ImportHeader."Import Time" := Time;
        ImportHeader."User ID" := CopyStr(UserId(), 1, MaxStrLen(importHeader."User ID"));
        ImportHeader.Modify();

        success := true;
    end;

    local procedure createImportLinesYoutrack(workItemDataObject: JsonObject; FromDate: Date; ToDate: Date) success: Boolean
    var
        tempImportLine: Record "TWE Proj. Inv. Import Line" temporary;
        importLine: Record "TWE Proj. Inv. Import Line";
        projectHours: Record "TWE Proj. Inv. Project Hours";
    begin
        success := false;

        tempImportLine.Init();
        tempImportLine."Import Header ID" := importHeader.GetLastEntryNo();
        if FirstLine then
            tempImportLine."Line No" := importLine.GetLastLineNo(tempImportLine."Import Header ID") + 10000
        else begin
            tempImportLine."Line No" := 10000;
            FirstLine := true;
        end;
        tempImportLine."Project Mgt. System" := "TWE Project Mgt. System"::YoutTrack;
        tempImportLine.Insert();

        tempImportLine.PopulateFromJsonYoutrack(workItemDataObject);

        tempImportLine.Modify();

        if (tempImportLine."WorkItem Created at" >= FromDate) and (tempImportLine."WorkItem Created at" <= ToDate) then
            if not projectHours.IsEmpty() then begin
                projectHours.SetRange(ID, tempImportLine."WorkItem ID");
                if projectHours.IsEmpty() then begin
                    importLine := tempImportLine;
                    importLine.Insert();
                end;
                projectHours.Reset();
            end else begin
                importLine.Init();
                importLine := tempImportLine;
                importLine.Insert();
            end;

        success := true;
    end;

    local procedure createImportLinesJIRA(workItemDataObject: JsonObject) success: Boolean
    var
        tempImportLine: Record "TWE Proj. Inv. Import Line" temporary;
        importLine: Record "TWE Proj. Inv. Import Line";
        jsonMethods: Codeunit "TWE JSONMethods";
        workItemToken: JsonToken;
        workItemArray: JsonArray;
        workItemObjectLocal: JsonObject;
        lineNo: Integer;
    begin
        success := false;
        lineNo := 0;
        workItemDataObject.Get('worklogs', workItemToken);
        workItemArray := workItemToken.AsArray();

        foreach workItemToken in workItemArray do begin
            workItemObjectLocal := workItemToken.AsObject();
            jsonMethods.SetJsonObject(workItemObjectLocal);

            tempImportLine.Init();
            tempImportLine."Import Header ID" := importHeader.GetLastEntryNo();
            lineNo += 10000;
            tempImportLine."Line No" := lineNo;
            tempImportLine."Project Mgt. System" := "TWE Project Mgt. System"::YoutTrack;
            tempImportLine.Insert();

            tempImportLine.PopulateFromJsonJIRA(workItemObjectLocal, "TWE Proj. Inv. ProjMgt. Objects"::workItem);
            //tempImportLine.PopulateFromJsonJIRA(projectDataObject, "TWE Proj. Inv. ProjMgt. Objects"::project);

            tempImportLine.Modify();
        end;

        repeat
            if (tempImportLine."WorkItem Created at" >= FromDate) and (tempImportLine."WorkItem Created at" <= ToDate) then
                if not importLine.IsEmpty() then begin
                    importLine.SetRange("WorkItem ID", tempImportLine."WorkItem ID");
                    if importLine.IsEmpty() then begin
                        importLine := tempImportLine;
                        importLine.Insert();
                    end;
                    importLine.Reset();
                end else begin
                    importLine.Init();
                    importLine := tempImportLine;
                    importLine.Insert();
                end;
        until tempImportLine.Next() = 0;
        success := true;
    end;

    local procedure initArguments(var RESTArguments: Record "TWE RESTWebServiceArguments" temporary; Method: Text; ProjMgtSystem: Enum "TWE Project Mgt. System"; UsePermToken: Boolean)
    var
        oAuthApp: Record "TWE OAuth 2.0 Application";
        restWebService: Codeunit "TWE RESTWebServiceCode";
    begin
        RESTArguments.URL := getEndpoint(ProjMgtSystem) + Method;
        if UsePermToken then
            case ProjMgtSystem of
                ProjMgtSystem::YoutTrack:
                    RESTArguments.UserName := CopyStr(getPermToken(ProjMgtSystem), 1, MaxStrLen(RESTArguments.UserName));
                ProjMgtSystem::"JIRA Tempo":
                    RESTArguments.UserName := CopyStr(getUserName(ProjMgtSystem) + ':' + getPermToken(ProjMgtSystem), 1, MaxStrLen(RESTArguments.UserName));
            end
        else begin
            oAuthApp.SetRange("TWE Project Mgt. System", ProjMgtSystem);
            if oAuthApp.FindFirst() then
                restWebService.setAuthorization(RESTArguments, oAuthApp.Code);
        end;
    end;

    local procedure getPermToken(ProjMgtSystem: Enum "TWE Project Mgt. System"): Text
    var
        oAuthApp: Record "TWE OAuth 2.0 Application";
    begin
        oAuthApp.SetRange("TWE Project Mgt. System", ProjMgtSystem);
        if oAuthApp.FindFirst() then
            oAuthApp.TestField("TWE Proj. Inv. PermToken");

        exit(oAuthApp."TWE Proj. Inv. PermToken");
    end;

    local procedure getUserName(ProjMgtSystem: Enum "TWE Project Mgt. System"): Text
    var
        oAuthApp: Record "TWE OAuth 2.0 Application";
    begin
        oAuthApp.SetRange("TWE Project Mgt. System", ProjMgtSystem);
        if oAuthApp.FindFirst() then
            oAuthApp.TestField("User Name");

        exit(oAuthApp."User Name");
    end;

    local procedure getPassword(ProjMgtSystem: Enum "TWE Project Mgt. System"): Text
    var
        oAuthApp: Record "TWE OAuth 2.0 Application";
    begin
        oAuthApp.SetRange("TWE Project Mgt. System", ProjMgtSystem);
        if oAuthApp.FindFirst() then
            oAuthApp.TestField(Password);

        exit(oAuthApp.Password);
    end;

    local procedure getEndpoint(ProjMgtSystem: Enum "TWE Project Mgt. System"): Text
    var
        oAuthApp: Record "TWE OAuth 2.0 Application";
    begin
        oAuthApp.SetRange("TWE Project Mgt. System", ProjMgtSystem);
        if oAuthApp.FindFirst() then
            oAuthApp.TestField("TWE Proj. Inv. Endpoint");

        exit(oAuthApp."TWE Proj. Inv. Endpoint");
    end;

    local procedure callWebService(var RESTArguments: Record "TWE RESTWebServiceArguments" temporary; ProjMgtSystem: Enum "TWE Project Mgt. System") success: Boolean
    var
    begin
        success := callRESTWebService(RESTArguments, ProjMgtSystem);
    end;

    local procedure callRESTWebService(var Parameters: Record "TWE RESTWebServiceArguments"; ProjMgtSystem: Enum "TWE Project Mgt. System"): Boolean
    var
        base64Convert: Codeunit "Base64 Convert";
        client: HttpClient;
        headers: HttpHeaders;
        requestMessage: HttpRequestMessage;
        responseMessage: HttpResponseMessage;
        content: HttpContent;
        authText: text;
        strSubstBearerAuthorizationLbl: Label 'Bearer %1', Comment = '%1=Token', Locked = true;
        strSubstBasicAuthorizationLbl: Label 'Basic %1', Comment = '%1=Token', Locked = true;
        SetHeaders: HttpHeaders;
    begin
        RequestMessage.Method := Format(Parameters.RestMethod);
        RequestMessage.SetRequestUri(Parameters.URL);

        RequestMessage.GetHeaders(Headers);

        if Parameters.Accept <> '' then
            Headers.Add('Accept', Parameters.Accept);

        if Parameters.UserName <> '' then begin
            case ProjMgtSystem of
                ProjMgtSystem::YoutTrack:
                    authText := StrSubstNo(strSubstBearerAuthorizationLbl, Parameters.UserName);
                ProjMgtSystem::"JIRA Tempo":
                    authText := StrSubstNo(strSubstBasicAuthorizationLbl, base64Convert.ToBase64(Parameters.UserName));
            end;

            Headers.Add('Authorization', authText);
        end;

        if Parameters.HasRequestContent() then begin
            Parameters.GetRequestContent(content);
            content.GetHeaders(SetHeaders);
            if SetHeaders.Contains('Content-Type') then
                SetHeaders.Remove('Content-Type');
            SetHeaders.Add('Content-Type', 'application/json');
            RequestMessage.Content := Content;
        end;

        client.Send(RequestMessage, ResponseMessage);

        Headers := ResponseMessage.Headers();
        Parameters.SetResponseHeaders(Headers);

        Content := ResponseMessage.Content();
        Parameters.SetResponseContent(Content);

        EXIT(ResponseMessage.IsSuccessStatusCode());
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
}