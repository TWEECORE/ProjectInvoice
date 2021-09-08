/// <summary>
/// Codeunit TWE Proj. Inv. Import Mgt (ID 70704952).
/// </summary>
codeunit 70704952 "TWE Proj. Inv. Import Mgt"
{
    var
        ImportHeader: Record "TWE Proj. Inv. Import Header";
        BaseMgt: Codeunit "TWE Base Mgt";
        ErrDataReceiveFailedLbl: Label 'Could not receive data.';
        MsgNoProjectDataFoundLbl: Label 'No new project data available.';
        youtrackWorkitemArgumentsLbl: Label '/workItems?fields=$type,id,author($type,login),issue($type,idReadable,summary,created,project($type,shortName,name),reporter($type,login)),date,text,duration($type,minutes)&$skip=0&$top=10000';
        jiraWorkLogArgumentsLbl: Label '/worklog/updated?since=';
        noPermTokenFoundLbl: Label 'There is no Permanent Token defined for Application "%1"', Comment = '%1=ProjectMgtSystem';
        noDataToImportLbl: Label 'There are no new project hours to import';

        FirstLine: Boolean;


    /// <summary>
    /// GetProjectMgtSystemDataByDate.
    /// </summary>
    /// <param name="requestFromDate">Date.</param>
    /// <param name="requestToDate">Date.</param>
    /// <returns>Return variable success of type Boolean.</returns>
    procedure GetProjectMgtSystemDataByDate(requestFromDate: Date; requestToDate: Date) success: Boolean
    begin
        if not requestProjectData(requestFromDate, requestToDate) then
            Error(MsgNoProjectDataFoundLbl);
    end;

    local procedure requestProjectData(requestFromDate: Date; requestToDate: Date) success: Boolean
    var
        oAuthApp: Record "TWE OAuth 2.0 Application";
        importLine: Record "TWE Proj. Inv. Import Line";
    begin
        success := false;

        oAuthApp.SetRange("TWE Use Project Mgt. System", true);
        if oAuthApp.FindSet() then begin
            createImportHeader(ImportHeader);
            repeat
                if oAuthApp."TWE Use Permanent Token" then begin
                    if oAuthApp."TWE Proj. Inv. PermToken" <> '' then
                        case oAuthApp.Code of
                            Format("TWE Project Mgt. System"::YoutTrack):
                                begin
                                    FirstLine := false;
                                    requestDataViaPermToken("TWE Project Mgt. System"::YoutTrack, requestFromDate, requestToDate);
                                end;
                            Format("TWE Project Mgt. System"::JIRA):
                                begin
                                    FirstLine := false;
                                    requestDataViaPermToken("TWE Project Mgt. System"::JIRA, requestFromDate, requestToDate);
                                end;
                        end
                    else
                        Message(noPermTokenFoundLbl, Format(oAuthApp.Description));
                end else
                    case oAuthApp.Code of
                        Format("TWE Project Mgt. System"::YoutTrack):
                            begin
                                FirstLine := false;
                                requestDataViaOAuth("TWE Project Mgt. System"::YoutTrack, requestFromDate, requestToDate);
                            end;
                        Format("TWE Project Mgt. System"::JIRA):
                            begin
                                FirstLine := false;
                                requestDataViaOAuth("TWE Project Mgt. System"::JIRA, requestFromDate, requestToDate);
                            end;
                    end;
            until oAuthApp.Next() = 0;

            importline.SetRange("Import Header ID", ImportHeader."Entry No.");
            if importLine.IsEmpty() then begin
                Message(noDataToImportLbl);
                ImportHeader.Delete();
            end;
        end;
        success := true;
    end;

    local procedure requestDataViaPermToken(ProjMgtSystem: Enum "TWE Project Mgt. System"; RequestFromDate: Date; RequestToDate: Date) success: Boolean
    var
        tempArguments: Record "TWE RESTWebServiceArguments" temporary;
        jsonMethods: Codeunit "TWE JSONMethods";
        response: JsonObject;
        issueObject: JsonObject;
        workItemObject: JsonObject;
        jToken: JsonToken;
        workItemArray: JsonArray;
    begin
        success := false;
        case ProjMgtSystem of
            ProjMgtSystem::YoutTrack:
                begin
                    tempArguments.RestMethod := tempArguments.RestMethod::get;
                    initArgumentsPermToken(tempArguments, youtrackWorkitemArgumentsLbl, "TWE Project Mgt. System"::YoutTrack);
                    if not callWebService(tempArguments, ProjMgtSystem::YoutTrack) then
                        Error('%1\\%2', ErrDataReceiveFailedLbl, tempArguments.GetResponseContentAsText());

                    workItemArray.ReadFrom(tempArguments.GetResponseContentAsText());
                    foreach jToken in workItemArray do begin
                        workItemObject := jToken.AsObject();
                        jsonMethods.SetJsonObject(workItemObject);
                        createImportLinesYoutrack(workItemObject, requestFromDate, requestToDate);
                    end;
                end;
            ProjMgtSystem::JIRA:
                begin
                    tempArguments.RestMethod := tempArguments.RestMethod::get;
                    initArgumentsPermToken(tempArguments, jiraWorkLogArgumentsLbl + Format(BaseMgt.getUnixTimeStampFromDate(RequestFromDate)), "TWE Project Mgt. System"::JIRA);
                    if not callWebService(tempArguments, ProjMgtSystem::YoutTrack) then
                        Error('%1\\%2', ErrDataReceiveFailedLbl, tempArguments.GetResponseContentAsText());

                    response.ReadFrom(tempArguments.GetResponseContentAsText());
                    workItemObject := response;

                    workItemArray.ReadFrom(tempArguments.GetResponseContentAsText());
                    foreach jToken in workItemArray do begin
                        workItemObject := jToken.AsObject();
                        jsonMethods.SetJsonObject(workItemObject);
                        createImportLinesYoutrack(workItemObject, requestFromDate, requestToDate);
                    end;

                    tempArguments.Reset();
                    tempArguments.RestMethod := tempArguments.RestMethod::get;
                    initArgumentsPermToken(tempArguments, '/project', "TWE Project Mgt. System"::YoutTrack);
                    if not callWebService(tempArguments, ProjMgtSystem::YoutTrack) then
                        Error('%1\\%2', ErrDataReceiveFailedLbl, tempArguments.GetResponseContentAsText());

                    response.ReadFrom(tempArguments.GetResponseContentAsText());
                    //projectObject := response;

                    //TODO: WorklogAusgabe für Datumsbestimmung prüfen
                    //createImportLinesJIRA(projectObject, workItemObject, requestFromDate, requestToDate);
                    addIssueDataToImportLine(issueObject, workItemObject);
                end;
        end;
        success := true;
    end;

    local procedure requestDataViaOAuth(ProjMgtSystem: Enum "TWE Project Mgt. System"; RequestFromDate: Date; RequestToDate: Date) success: Boolean
    var
        tempArguments: Record "TWE RESTWebServiceArguments" temporary;
        oAuthApp: Record "TWE OAuth 2.0 Application";
        jsonnMethods: Codeunit "TWE JSONMethods";
        workItemObject: JsonObject;
        jToken: JsonToken;
        workItemArray: JsonArray;
    begin
        success := false;
        case ProjMgtSystem of
            ProjMgtSystem::YoutTrack:
                begin
                    tempArguments.RestMethod := tempArguments.RestMethod::get;
                    initArguments(tempArguments, youtrackWorkitemArgumentsLbl, oAuthApp.Code, oAuthApp."TWE Proj. Inv. Endpoint");
                    if not callWebService(tempArguments, ProjMgtSystem::YoutTrack) then
                        Error('%1\\%2', ErrDataReceiveFailedLbl, tempArguments.GetResponseContentAsText());

                    workItemArray.ReadFrom(tempArguments.GetResponseContentAsText());
                    foreach jToken in workItemArray do begin
                        workItemObject := jToken.AsObject();
                        jsonnMethods.SetJsonObject(workItemObject);
                        createImportLinesYoutrack(workItemObject, requestFromDate, requestToDate);
                    end;
                end;
            ProjMgtSystem::JIRA:
                Message('TODO:JIRA');
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

    local procedure createImportLinesJIRA(projectDataObject: JsonObject; workItemDataObject: JsonObject; FromDate: Date; ToDate: Date) success: Boolean
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
            tempImportLine.PopulateFromJsonJIRA(projectDataObject, "TWE Proj. Inv. ProjMgt. Objects"::project);

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

    local procedure initArguments(var RESTArguments: Record "TWE RESTWebServiceArguments" temporary; Method: Text; "OAuth AppCode": Code[20]; EndPoint: Text)
    var
        restWebService: Codeunit "TWE RESTWebServiceCode";
    begin
        RESTArguments.URL := EndPoint + Method;

        restWebService.setAuthorization(RESTArguments, "OAuth AppCode");
    end;

    local procedure initArgumentsPermToken(var RESTArguments: Record "TWE RESTWebServiceArguments" temporary; Method: Text; ProjMgtSystem: Enum "TWE Project Mgt. System")
    begin
        RESTArguments.URL := getEndpoint(Format(ProjMgtSystem)) + Method;
        case ProjMgtSystem of
            ProjMgtSystem::YoutTrack:
                RESTArguments.UserName := CopyStr(getPermToken(Format(ProjMgtSystem)), 1, MaxStrLen(RESTArguments.UserName));
            ProjMgtSystem::JIRA:
                RESTArguments.UserName := CopyStr(getJIRAUserName(Format(ProjMgtSystem)) + ':' + getPermToken(Format(ProjMgtSystem)), 1, MaxStrLen(RESTArguments.UserName));
        end;
    end;

    local procedure getPermToken(OAuthAppCode: Code[20]): Text
    var
        oAuthApp: Record "TWE OAuth 2.0 Application";
    begin
        oAuthApp.Get(OAuthAppCode);
        oAuthApp.TestField("TWE Proj. Inv. PermToken");

        exit(oAuthApp."TWE Proj. Inv. PermToken");
    end;

    local procedure getJIRAUserName(OAuthAppCode: Code[20]): Text
    var
        oAuthApp: Record "TWE OAuth 2.0 Application";
    begin
        oAuthApp.Get(OAuthAppCode);
        oAuthApp.TestField("User Name");

        exit(oAuthApp."User Name");
    end;

    local procedure getPassword(OAuthAppCode: Code[20]): Text
    var
        oAuthApp: Record "TWE OAuth 2.0 Application";
    begin
        oAuthApp.Get(OAuthAppCode);
        oAuthApp.TestField(Password);

        exit(oAuthApp.Password);
    end;

    local procedure getEndpoint(OAuthAppCode: Code[20]): Text
    var
        oAuthApp: Record "TWE OAuth 2.0 Application";
    begin
        oAuthApp.Get(OAuthAppCode);
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
                ProjMgtSystem::JIRA:
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

    procedure ImportProjects() success: Boolean
    var
        oAuthApp: Record "TWE OAuth 2.0 Application";
    begin
        success := false;

        oAuthApp.SetRange("TWE Use Project Mgt. System", true);
        if oAuthApp.FindSet() then begin
            createImportHeader(ImportHeader);
            repeat
                if oAuthApp."TWE Use Permanent Token" then begin
                    if oAuthApp."TWE Proj. Inv. PermToken" <> '' then
                        case oAuthApp.Code of
                            Format("TWE Project Mgt. System"::YoutTrack):
                                begin
                                    FirstLine := false;
                                    requestProjectData("TWE Project Mgt. System"::YoutTrack, true);
                                end;
                            Format("TWE Project Mgt. System"::JIRA):
                                begin
                                    FirstLine := false;
                                    requestProjectData("TWE Project Mgt. System"::JIRA, true);
                                end;
                        end
                    else
                        Message(noPermTokenFoundLbl, Format(oAuthApp.Description));
                end else
                    case oAuthApp.Code of
                        Format("TWE Project Mgt. System"::YoutTrack):
                            begin
                                FirstLine := false;
                                requestProjectData("TWE Project Mgt. System"::YoutTrack, false);
                            end;
                        Format("TWE Project Mgt. System"::JIRA):
                            begin
                                FirstLine := false;
                                requestProjectData("TWE Project Mgt. System"::JIRA, false);
                            end;
                    end;
            until oAuthApp.Next() = 0;
        end;
        success := true;
    end;

    local procedure requestProjectData(ProjMgtSystem: Enum "TWE Project Mgt. System"; PermToken: Boolean) success: Boolean
    var
        tempArguments: Record "TWE RESTWebServiceArguments" temporary;
        jsonMethods: Codeunit "TWE JSONMethods";
        response: JsonObject;
        issueObject: JsonObject;
        workItemObject: JsonObject;
        jToken: JsonToken;
        workItemArray: JsonArray;
    begin

    end;

    local procedure addIssueDataToImportLine(IssueObject: JsonObject; WorkItemObject: JsonObject)
    var
        tempArguments: Record "TWE RESTWebServiceArguments" temporary;
        jsonMethods: Codeunit "TWE JSONMethods";
        response: JsonObject;
        itemObject: JsonObject;
        jToken: JsonToken;
        jsonObjArray: JsonArray;
        idList: text;
    begin
        WorkItemObject.Get('ChangedWorkLogs', jToken);
        jsonObjArray := jToken.AsArray();
        foreach jToken in jsonObjArray do begin
            itemObject := jToken.AsObject();
            JSONMethods.SetJsonObject(itemObject);
            idList += jsonMethods.GetJsonValue('issue ID').AsText() + ',';
        end;

        //TODO: IssueAbfrage + Übernahme in Importline
        //tempImportLine.PopulateFromJsonYoutrack(issueDataObject, "TWE Proj. Inv. ProjMgt. Objects"::issue);
        //tempImportLine.Modify();
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