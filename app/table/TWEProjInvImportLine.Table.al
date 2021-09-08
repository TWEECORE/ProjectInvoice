/// <summary>
/// Table TWE Proj. Inv. Import Line (ID 70704953).
/// </summary>
table 70704953 "TWE Proj. Inv. Import Line"
{
    DataClassification = CustomerContent;
    Caption = 'Project Invoice Import Line';

    fields
    {
        field(1; "Import Header ID"; Integer)
        {
            Caption = 'Import Header ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; "Line No"; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Project ID"; Text[50])
        {
            Caption = 'Project ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; "Project Name"; Text[150])
        {
            Caption = 'Project Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7; "Project Mgt. System"; Enum "TWE Project Mgt. System")
        {
            Caption = 'Project Mgt. System';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Ticket No."; Text[50])
        {
            Caption = 'Ticket No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Ticket Name"; Text[150])
        {
            Caption = 'Ticket Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; Agent; Text[50])
        {
            Caption = 'Agent';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "Ticket Creator"; Text[50])
        {
            Caption = 'Ticket Creator';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(15; Hours; Decimal)
        {
            Caption = 'Hours';
            DataClassification = CustomerContent;
            DecimalPlaces = 2;
        }
        field(20; Imported; Boolean)
        {
            Caption = 'Imported';
            DataClassification = CustomerContent;
        }
        field(25; "Ticket Created at"; Date)
        {
            Caption = 'Ticket Created at';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(30; "WorkItem Created at"; Date)
        {
            Caption = 'WorkItem Created at';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(35; "WorkItem ID"; Code[50])
        {
            Caption = 'WorkItem ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(40; "WorkItem Description"; Text[150])
        {
            Caption = 'WorkItem Description';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Import Header ID", "Line No")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;


    /// <summary>
    /// PopulateFromJsonYoutrack.
    /// </summary>
    /// <param name="jsonData">JsonObject.</param>
    procedure PopulateFromJsonYoutrack(jsonData: JsonObject)
    var
        jSONMethods: Codeunit "TWE JSONMethods";
        projInvImportMgt: Codeunit "TWE Proj. Inv. Import Mgt";
        helperJson: JsonObject;
        projectJson: JsonObject;
        reporterJson: JsonObject;
        JToken: JsonToken;
    begin
        jsonMethods.SetJsonObject(jsonData);

        "WorkItem ID" := CopyStr(jSONMethods.GetJsonValue('id').AsText(), 1, MaxStrLen("WorkItem ID"));
        if not JSONMethods.IsNullValue('text') then
            "WorkItem Description" := convertUmlaute(CopyStr(jSONMethods.GetJsonValue('text').AsText(), 1, MaxStrLen("WorkItem Description")));
        "WorkItem Created at" := projInvImportMgt.getDateFromUnixTimeStamp(jSONMethods.GetJsonValue('date').AsText());
        jsonData.Get('author', JToken);
        if JToken.IsObject then begin
            helperJson := JToken.AsObject();
            JSONMethods.SetJsonObject(helperJson);
            Agent := CopyStr(jSONMethods.GetJsonValue('login').AsText(), 1, MaxStrLen(Agent));
        end;

        jsonData.Get('duration', JToken);
        if JToken.IsObject then begin
            helperJson := JToken.AsObject();
            JSONMethods.SetJsonObject(helperJson);
            Hours := jSONMethods.GetJsonValue('minutes').AsInteger() / 60;
        end;

        jsonData.Get('issue', JToken);
        if JToken.IsObject then begin
            helperJson := JToken.AsObject();
            JSONMethods.SetJsonObject(helperJson);
            "Ticket No." := CopyStr(jSONMethods.GetJsonValue('idReadable').AsText(), 1, MaxStrLen("Ticket No."));
            if not JSONMethods.IsNullValue('summary') then
                "Ticket Name" := convertUmlaute(CopyStr(jSONMethods.GetJsonValue('summary').AsText(), 1, MaxStrLen("Ticket Name")));
            "Ticket Created at" := projInvImportMgt.getDateFromUnixTimeStamp(jSONMethods.GetJsonValue('created').AsText());

            helperJson.Get('reporter', JToken);
            if JToken.IsObject then begin
                reporterJson := JToken.AsObject();
                JSONMethods.SetJsonObject(reporterJson);
                "Ticket Creator" := CopyStr(jSONMethods.GetJsonValue('login').AsText(), 1, MaxStrLen("Ticket Creator"));
            end;

            helperJson.Get('project', JToken);
            if JToken.IsObject then begin
                projectJson := JToken.AsObject();
                JSONMethods.SetJsonObject(projectJson);
                "Project ID" := CopyStr(jSONMethods.GetJsonValue('shortName').AsText(), 1, MaxStrLen("Project ID"));
                if not JSONMethods.IsNullValue('name') then
                    "Project Name" := CopyStr(jSONMethods.GetJsonValue('name').AsText(), 1, MaxStrLen("Project ID"));
            end;
        end;
    end;

    /// <summary>
    /// PopulateFromJsonJIRA.
    /// </summary>
    /// <param name="jsonData">JsonObject.</param>
    procedure PopulateFromJsonJIRA(jsonData: JsonObject; ProjMgtObject: Enum "TWE Proj. Inv. ProjMgt. Objects")
    var
        importHeader: Record "TWE Proj. Inv. Import Header";
        jSONMethods: Codeunit "TWE JSONMethods";
        projInvImportMgt: Codeunit "TWE Proj. Inv. Import Mgt";
        localJsonObject: JsonObject;
        localToken: JsonToken;
        localArray: JsonArray;
    begin
        case ProjMgtObject of
            "TWE Proj. Inv. ProjMgt. Objects"::workItem:
                begin
                    jsonMethods.SetJsonObject(jsonData);

                    "Ticket No." := CopyStr(jSONMethods.GetJsonValue('issueID').AsText(), 1, MaxStrLen("Ticket No."));
                    "WorkItem ID" := CopyStr(jSONMethods.GetJsonValue('id').AsText(), 1, MaxStrLen("WorkItem ID"));
                    "WorkItem Description" := CopyStr(jSONMethods.GetJsonValue('comment').AsText(), 1, MaxStrLen("WorkItem Description"));
                    "WorkItem Created at" := projInvImportMgt.getDateFromUnixTimeStamp(jSONMethods.GetJsonValue('started').AsText());
                    //TODO: Author {displayname}
                    //Agent := CopyStr(jSONMethods.GetJsonValue('author').AsText(), 1, MaxStrLen(Agent));
                    Hours := jSONMethods.GetJsonValue('timeSpentseconds').AsInteger() / 3600;
                end;
            "TWE Proj. Inv. ProjMgt. Objects"::issue:
                begin
                    jsonData.Get('issues', localToken);
                    localArray := localToken.AsArray();

                    foreach localToken in localArray do begin
                        jsonData := localToken.AsObject();
                        jsonMethods.SetJsonObject(localJsonObject);

                        if jSONMethods.GetJsonValue('ID').AsText() = "Ticket No." then begin
                            "Ticket Name" := CopyStr(jSONMethods.GetJsonValue('description').AsText(), 1, MaxStrLen("Ticket Name"));
                            //TODO: comment{author{Displayname}}
                            "Ticket Creator" := CopyStr(jSONMethods.GetJsonValue('displayname').AsText(), 1, MaxStrLen("Ticket Creator"));
                            //TODO: comment{created}
                            "Ticket Created at" := projInvImportMgt.getDateFromUnixTimeStamp(jSONMethods.GetJsonValue('created').AsText());
                            //TODO: project{id, name}
                            "Project ID" := CopyStr(jSONMethods.GetJsonValue('id').AsText(), 1, MaxStrLen("Project ID"));
                            "Project Name" := CopyStr(jSONMethods.GetJsonValue('name').AsText(), 1, MaxStrLen("Project Name"));
                        end;
                    end;
                end;
        end;
    end;

    /// <summary>
    /// GetLastLineNo.
    /// </summary>
    /// <param name="ImportHeaderEntryNo">Integer.</param>
    /// <returns>Return value of type Integer.</returns>
    procedure GetLastLineNo(ImportHeaderEntryNo: Integer): Integer;
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        rec.SetRange("Import Header ID", ImportHeaderEntryNo);
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo("Line No")))
    end;

    local procedure convertUmlaute(String: Text[150]) ConvertedString: text[150]
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
}