/// <summary>
/// Codeunit TWE Proj. Inv. Import Mgt (ID 70704952).
/// </summary>
codeunit 70704952 "TWE Proj. Inv. Import Mgt"
{
    var
        GlobalImportHeader: Record "TWE Proj. Inv. Import Header";
        BaseMgt: Codeunit "TWE Base Mgt";
        FromDate: Date;
        ToDate: Date;
        ErrDataReceiveFailedLbl: Label 'Could not receive data.';
        MsgNoProjectDataFoundLbl: Label 'No new project data available.';
        YoutrackWorkitemArgumentsLbl: Label '/youtrack/api/workItems?fields=$type,id,author($type,login),issue($type,idReadable,summary,created,project($type,shortName,name),reporter($type,login)),date,text,duration($type,minutes)&$skip=0&$top=10000';
        YoutrackProjectArgumentsLbl: Label '/youtrack/api/admin/projects?fields=$type,shortName,name&$skip=0&$top=10000';
        TempoWorkLogArgumentsLbl: Label '/core/3/worklogs/issue/%1&limit=1000', Comment = '%1=IssueID';
        JiraIssuesArgumentsLbl: Label '/rest/api/2/search?jql=worklogDate>0';//TODO:ORDER%20BY%20Created';
        JiraWorkLogsArgumentsLbl: Label '/rest/api/2/issue/%1/worklog', Comment = '%1=IssueID';
        JiraProjectArgumentsLbl: Label '/rest/api/2/project';
        NoDataToImportLbl: Label 'There is no new project data to import';
        noProjMgtApiDataErr: Label 'Did not found any Project Management API Data. Please execute the Project Invoice Assisted Setup.';
        UseTempoTimeSheets: Boolean;
        FirstLine: Boolean;

    /// <summary>
    /// GetProjectDataByDate.
    /// </summary>
    /// <param name="requestFromDate">Date.</param>
    /// <param name="requestToDate">Date.</param>
    procedure GetProjectDataByDate(requestFromDate: Date; requestToDate: Date)
    begin
        if requestFromDate <> 0D then
            if requestToDate <> 0D then begin
                FromDate := requestFromDate;
                ToDate := requestToDate;
            end else begin
                FromDate := requestFromDate;
                ToDate := Today;
            end
        else
            if requestToDate <> 0D then
                ToDate := requestToDate;

        if not requestProjectHourData() then
            Error(MsgNoProjectDataFoundLbl);
    end;

    /// <summary>
    /// RequestAllProjects.
    /// </summary>
    /// <returns>Return variable success of type Boolean.</returns>
    procedure RequestAllProjects() success: Boolean
    var
        oAuthApp: Record "TWE OAuth 2.0 Application";
        importToken: JsonToken;
    begin
        success := false;

        oAuthApp.SetRange("TWE Is Project Mgt. System", true);
        if oAuthApp.FindSet() then
            repeat
                if oAuthApp."TWE Project Mgt. System" = oAuthApp."TWE Project Mgt. System"::YoutTrack then
                    importToken := requestData(oAuthApp."TWE Project Mgt. System", YoutrackProjectArgumentsLbl, oAuthApp."TWE Use Permanent Token", '', true)
                else
                    importToken := requestData(oAuthApp."TWE Project Mgt. System", JiraProjectArgumentsLbl, oAuthApp."TWE Use Permanent Token", '', true);
                importProjects(importToken, oAuthApp);
            until oAuthApp.Next() = 0;
        success := true;
    end;

    local procedure importProjects(ImportToken: JsonToken; oAuthApp: Record "TWE OAuth 2.0 Application")
    var
        ProjInvProject: Record "TWE Proj. Inv. Project";
        jsonMethods: Codeunit "TWE JSONMethods";
        workItemObject: JsonObject;
        itemArray: JsonArray;
        jToken: JsonToken;
    begin
        itemArray := ImportToken.AsArray();
        foreach jToken in itemArray do begin
            workItemObject := jToken.AsObject();
            jsonMethods.SetJsonObject(workItemObject);

            ProjInvProject.PopulateFromJson(workItemObject, oAuthApp."TWE Project Mgt. System");
        end;
    end;

    local procedure requestProjectHourData() success: Boolean
    var
        oAuthApp: Record "TWE OAuth 2.0 Application";
        importLine: Record "TWE Proj. Inv. Import Line";
        processingMgt: Codeunit "TWE Proj. Inv. Processing Mgt";
        importItemToken: JsonToken;
        RequestInformation: Text;
        projMgtApiDataFound: Boolean;
    begin
        success := false;
        projMgtApiDataFound := false;

        oAuthApp.SetRange("TWE Is Project Mgt. System", true);
        if oAuthApp.FindSet() then begin
            createImportHeader(GlobalImportHeader);
            if GlobalImportHeader.FindLast() then;
            repeat
                case oAuthApp."TWE Project Mgt. System" of
                    oAuthApp."TWE Project Mgt. System"::YoutTrack:
                        RequestInformation := YoutrackWorkitemArgumentsLbl;
                    else
                        if oAuthApp."TWE Project Mgt. System" <> oAuthApp."TWE Project Mgt. System"::" " then
                            RequestInformation := JiraIssuesArgumentsLbl;
                end;

                if RequestInformation <> '' then begin
                    if oAuthApp."TWE Project Mgt. System" = oAuthApp."TWE Project Mgt. System"::"JIRA Tempo" then
                        UseTempoTimeSheets := true;
                    importItemToken := requestData(oAuthApp."TWE Project Mgt. System", RequestInformation, oAuthApp."TWE Use Permanent Token", '', true);
                    createImportData(importItemToken, oAuthApp."TWE Project Mgt. System");
                    projMgtApiDataFound := true;
                end;
            until oAuthApp.Next() = 0;

            importline.SetRange("Import Header ID", GlobalImportHeader."Entry No.");
            if importLine.IsEmpty() then begin
                GlobalImportHeader.Delete();
                if projMgtApiDataFound then
                    Error(noProjMgtApiDataErr)
                else
                    Error(NoDataToImportLbl);
            end;

            processingMgt.TransferImportedData(GlobalImportHeader);
        end;
        success := true;
    end;

    local procedure requestData(ProjMgtSystem: Enum "TWE Project Mgt. System"; RequestString: Text; UsePermToken: Boolean; BodyInformation: Text;
                                GetMethod: Boolean) JToken: JsonToken
    var
        tempArguments: Record "TWE RESTWebServiceArguments" temporary;
        RequestHttpContent: HttpContent;
        RequestHeaders: HttpHeaders;
    begin
        UseTempoTimeSheets := false;

        if GetMethod then
            tempArguments.RestMethod := tempArguments.RestMethod::get
        else
            tempArguments.RestMethod := tempArguments.RestMethod::post;

        if BodyInformation <> '' then begin
            RequestHttpContent.WriteFrom(BodyInformation);

            tempArguments.SetRequestContent(RequestHttpContent);
            tempArguments.Accept := 'application/json';
            RequestHttpContent.GetHeaders(RequestHeaders);
            RequestHeaders.Remove('Content-Type');
            RequestHeaders.Add('Content-Type', 'application/json');
        end;

        if ProjMgtSystem <> ProjMgtSystem::" " then begin
            initArguments(tempArguments, RequestString, ProjMgtSystem, UsePermToken, false);

            if not callWebService(tempArguments, ProjMgtSystem) then
                Error('%1\\%2', ErrDataReceiveFailedLbl, tempArguments.GetResponseContentAsText());
        end;

        JToken.ReadFrom(tempArguments.GetResponseContentAsText());
    end;

    local procedure createImportData(WorkItemToken: JsonToken; ProjMgtSystem: Enum "TWE Project Mgt. System") success: Boolean
    var
        jsonMethods: Codeunit "TWE JSONMethods";
        workItemArray: JsonArray;
        workItemObject: JsonObject;
        jToken: JsonToken;
        isObject: Boolean;
    begin
        success := false;
        FirstLine := false;

        if WorkItemToken.IsArray then begin
            workItemArray := WorkItemToken.AsArray();
            isObject := false;
        end else begin
            workItemObject := WorkItemToken.AsObject();
            isObject := true;
        end;

        case ProjMgtSystem of
            ProjMgtSystem::YoutTrack:
                if not isObject then
                    foreach jToken in WorkitemArray do begin
                        workItemObject := jToken.AsObject();
                        jsonMethods.SetJsonObject(workItemObject);
                        createImportLinesYoutrack(workItemObject, FromDate, ToDate);
                    end
                else begin
                    jsonMethods.SetJsonObject(workItemObject);
                    createImportLinesYoutrack(workItemObject, FromDate, ToDate);
                end;
            else
                if ProjMgtSystem <> ProjMgtSystem::" " then
                    if not isObject then
                        foreach jToken in WorkitemArray do begin
                            workItemObject := jToken.AsObject();
                            jsonMethods.SetJsonObject(workItemObject);
                            createImportLinesJIRA(workItemObject, ProjMgtSystem);
                        end
                    else begin
                        jsonMethods.SetJsonObject(workItemObject);
                        createImportLinesJIRA(workItemObject, ProjMgtSystem);
                        if UseTempoTimeSheets then
                            getTempoTimeSheetDescription(GlobalImportHeader);
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
        tempImportLine."Import Header ID" := GlobalImportHeader.GetLastEntryNo();
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

        if ((FromDate = 0D) and (ToDate = 0D)) or ((FromDate = 0D) and (tempImportLine."WorkItem Created at" <= ToDate)) or
            ((tempImportLine."WorkItem Created at" <= FromDate) and (tempImportLine."WorkItem Created at" <= ToDate)) then
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

    local procedure createImportLinesJIRA(IssueDataObject: JsonObject; ProjMgtSystem: Enum "TWE Project Mgt. System") success: Boolean
    var
        tempImportLineIssues: Record "TWE Proj. Inv. Import Line" temporary;
        tempImportLineWorkItems: Record "TWE Proj. Inv. Import Line" temporary;
        importLine: Record "TWE Proj. Inv. Import Line";
        projectHour: Record "TWE Proj. Inv. Project Hours";
        jsonMethod: Codeunit "TWE JSONMethods";
        localJsonObject: JsonObject;
        startAt: Integer;
        maxResults: Integer;
        totalResults: Integer;
        jToken: JsonToken;
        jArray: JsonArray;
        isLast: Boolean;
        startAtStringLbl: Label '&startAt=';
    begin
        success := false;
        isLast := false;
        localJsonObject := IssueDataObject;

        repeat
            jsonMethod.SetJsonObject(localJsonObject);
            startAt := jsonMethod.GetJsonValue('startAt').AsInteger();
            maxResults := startAt + jsonMethod.GetJsonValue('maxResults').AsInteger();
            totalResults := jsonMethod.GetJsonValue('total').AsInteger();

            if localJsonObject.Get('issues', jToken) then
                if jToken.IsArray then begin
                    jArray := jToken.AsArray();
                    foreach jToken in jArray do begin
                        tempImportLineIssues.Init();
                        tempImportLineIssues."Import Header ID" := GlobalImportHeader.GetLastEntryNo();

                        tempImportLineIssues."Line No" := tempImportLineIssues.GetLastLineNo(tempImportLineIssues."Import Header ID") + 10000;

                        tempImportLineIssues."Project Mgt. System" := ProjMgtSystem;
                        tempImportLineIssues.Insert();

                        tempImportLineIssues.PopulateFromJsonJIRA(jToken.AsObject(), "TWE Proj. Inv. ProjMgt. Objects"::issue, true);

                        tempImportLineIssues.Modify();
                    end;
                end;

            if maxResults < totalResults then begin
                jToken := requestData(ProjMgtSystem, JiraIssuesArgumentsLbl + startAtStringLbl + Format(maxResults), true, '', true);
                localJsonObject := jToken.AsObject();
                isLast := false
            end else
                isLast := true;
        until isLast;

        isLast := false;
        maxResults := 0;
        tempImportLineIssues.Reset();
        if tempImportLineIssues.FindSet() then
            repeat
                if UseTempoTimeSheets then
                    jToken := requestData(ProjMgtSystem, StrSubstNo(JiraWorkLogsArgumentsLbl, tempImportLineIssues."Ticket No.") + startAtStringLbl + Format(maxResults), true, '', true)
                else
                    jToken := requestData(ProjMgtSystem, StrSubstNo(JiraWorkLogsArgumentsLbl, tempImportLineIssues."Ticket No.") + startAtStringLbl + Format(maxResults), true, '', true);
                localJsonObject := jToken.AsObject();

                repeat
                    jsonMethod.SetJsonObject(localJsonObject);
                    startAt := jsonMethod.GetJsonValue('startAt').AsInteger();
                    maxResults := startAt + jsonMethod.GetJsonValue('maxResults').AsInteger();
                    totalResults := jsonMethod.GetJsonValue('total').AsInteger();

                    if localJsonObject.Get('issues', jToken) then
                        if jToken.IsArray then begin
                            jArray := jToken.AsArray();
                            foreach jToken in jArray do begin
                                tempImportLineWorkItems.Init();
                                tempImportLineWorkItems."Import Header ID" := GlobalImportHeader.GetLastEntryNo();

                                tempImportLineWorkItems."Line No" := tempImportLineWorkItems.GetLastLineNo(tempImportLineWorkItems."Import Header ID") + 10000;

                                tempImportLineWorkItems."Project Mgt. System" := ProjMgtSystem;
                                tempImportLineWorkItems.Insert();

                                tempImportLineWorkItems.PopulateFromJsonJIRA(jToken.AsObject(), "TWE Proj. Inv. ProjMgt. Objects"::workItem, false);

                                tempImportLineWorkItems.Modify();
                            end;
                        end;

                    if maxResults < totalResults then begin
                        jToken := requestData(ProjMgtSystem, StrSubstNo(JiraWorkLogsArgumentsLbl, tempImportLineIssues."Ticket No.") + startAtStringLbl + Format(maxResults), true, '', true);
                        localJsonObject := jToken.AsObject();
                        isLast := false
                    end else
                        isLast := true;

                until isLast;
            until tempImportLineIssues.Next() = 0;

        tempImportLineWorkItems.Reset();
        if tempImportLineWorkItems.FindSet() then
            repeat
                projectHour.SetRange(ID, tempImportLineWorkItems."WorkItem ID");
                if projectHour.IsEmpty() then begin
                    importLine := tempImportLineWorkItems;
                    importLine.Insert();
                end;
            until tempImportLineWorkItems.Next() = 0;

        success := true;
    end;

    local procedure getTempoTimeSheetDescription(ImportHeader: Record "TWE Proj. Inv. Import Header")
    var
        importLine: Record "TWE Proj. Inv. Import Line";
        jSONMethods: Codeunit "TWE JSONMethods";
        workLogToken: JsonToken;
        workLogObject: JsonObject;
        workLogArray: JsonArray;
    begin
        workLogToken := requestData(importLine."Project Mgt. System", TempoWorkLogArgumentsLbl, true, '', true);
        if workLogToken.IsArray then begin
            workLogArray := workLogToken.AsArray();
            foreach workLogToken in workLogArray do begin
                workLogObject := workLogToken.AsObject();
                jSONMethods.SetJsonObject(workLogObject);
                importLine.SetRange("WorkItem ID", jSONMethods.GetJsonValue('jiraWorklogId').AsText());
                if importLine.FindFirst() then begin
                    importLine."WorkItem Description" := CopyStr(jSONMethods.GetJsonValue('description').AsText(), 1, MaxStrLen(importLine."WorkItem Description"));
                    importLine.Modify();
                end;
            end;
        end;

    end;

    local procedure initArguments(var RESTArguments: Record "TWE RESTWebServiceArguments" temporary; Method: Text; ProjMgtSystem: Enum "TWE Project Mgt. System"; UsePermToken: Boolean;
                                                                                                                                      TimeTracking: Boolean)
    var
        oAuthApp: Record "TWE OAuth 2.0 Application";
        restWebService: Codeunit "TWE RESTWebServiceCode";
    begin
        RESTArguments.URL := getEndpoint(ProjMgtSystem, TimeTracking) + Method;
        if UsePermToken then
            if TimeTracking then
                RESTArguments.UserName := CopyStr(getPermToken(ProjMgtSystem), 1, MaxStrLen(RESTArguments.UserName))
            else
                case ProjMgtSystem of
                    ProjMgtSystem::YoutTrack:
                        RESTArguments.UserName := CopyStr(getPermToken(ProjMgtSystem), 1, MaxStrLen(RESTArguments.UserName));
                    else
                        if ProjMgtSystem <> ProjMgtSystem::" " then
                            RESTArguments.UserName := CopyStr(getUserName(ProjMgtSystem) + ':' + getPermToken(ProjMgtSystem), 1, MaxStrLen(RESTArguments.UserName));
                end
        else begin
            //TODO TempoTimeSheets oAuth
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

    local procedure getEndpoint(ProjMgtSystem: Enum "TWE Project Mgt. System"; TimeTracking: Boolean): Text
    var
        oAuthApp: Record "TWE OAuth 2.0 Application";
    begin
        oAuthApp.SetRange("TWE Project Mgt. System", ProjMgtSystem);
        if oAuthApp.FindFirst() then
            if TimeTracking then begin
                oAuthApp.TestField("TWE PI Timetracking Endpoint");
                exit(oAuthApp."TWE PI Timetracking Endpoint");
            end else begin
                oAuthApp.TestField("TWE Proj. Inv. Endpoint");
                exit(oAuthApp."TWE Proj. Inv. Endpoint");
            end;
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
                else
                    if ProjMgtSystem <> ProjMgtSystem::" " then
                        authText := StrSubstNo(strSubstBasicAuthorizationLbl, base64Convert.ToBase64(Parameters.UserName));
            end;

            Headers.Add('Authorization', authText);
        end;

        if Parameters.ETag <> '' then
            Headers.Add('If-Match', Parameters.ETag);

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
}