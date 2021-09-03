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
        field(11; "Ticket Name"; Text[100])
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
    /// <param name="ProjMgtObject">Enum "TWE Proj. Inv. Youtrack Objects".</param>
    procedure PopulateFromJsonYoutrack(jsonData: JsonObject; ProjMgtObject: Enum "TWE Proj. Inv. ProjMgt. Objects")
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

                    "Ticket No." := CopyStr(jSONMethods.GetJsonValue('issue').AsText(), 1, MaxStrLen("Ticket No."));
                    "WorkItem ID" := CopyStr(jSONMethods.GetJsonValue('ID').AsText(), 1, MaxStrLen("WorkItem ID"));
                    "WorkItem Description" := CopyStr(jSONMethods.GetJsonValue('text').AsText(), 1, MaxStrLen("WorkItem Description"));
                    "WorkItem Created at" := projInvImportMgt.ConvertTextToDateTime(jSONMethods.GetJsonValue('created').AsText());
                    Agent := CopyStr(jSONMethods.GetJsonValue('author').AsText(), 1, MaxStrLen(Agent));
                    Hours := jSONMethods.GetJsonValue('duration').AsInteger() / 60;
                end;
            "TWE Proj. Inv. ProjMgt. Objects"::project:
                begin
                    jsonData.Get('projects', localToken);
                    localArray := localToken.AsArray();

                    foreach localToken in localArray do begin
                        jsonData := localToken.AsObject();
                        jsonMethods.SetJsonObject(localJsonObject);

                        if jSONMethods.GetJsonValue('shortname').AsText() = "Project ID" then
                            "Project Name" := CopyStr(JSONMethods.GetJsonValue('description').AsText(), 1, MaxStrLen("Project Name"));
                    end;
                end;
            "TWE Proj. Inv. ProjMgt. Objects"::issue:
                begin
                    jsonData.Get('issues', localToken);
                    localArray := localToken.AsArray();

                    foreach localToken in localArray do begin
                        jsonData := localToken.AsObject();
                        jsonMethods.SetJsonObject(localJsonObject);

                        if jSONMethods.GetJsonValue('ID').AsText() = "Ticket No." then begin
                            "Ticket Name" := CopyStr(jSONMethods.GetJsonValue('summary').AsText(), 1, MaxStrLen("Ticket Name"));
                            "Ticket Creator" := CopyStr(jSONMethods.GetJsonValue('Reporter').AsText(), 1, MaxStrLen("Ticket Creator"));
                            "Ticket Created at" := projInvImportMgt.ConvertTextToDateTime(jSONMethods.GetJsonValue('created').AsText());
                            "Project ID" := CopyStr(jSONMethods.GetJsonValue('project').AsText(), 1, MaxStrLen("Project ID"));
                        end;
                    end;
                end;
        end;

        "Import Header ID" := importHeader.GetLastEntryNo();
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
                    "WorkItem Created at" := projInvImportMgt.ConvertTextToDateTime(jSONMethods.GetJsonValue('started').AsText());
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
                            "Ticket Created at" := projInvImportMgt.ConvertTextToDateTime(jSONMethods.GetJsonValue('created').AsText());
                            //TODO: project{id, name}
                            "Project ID" := CopyStr(jSONMethods.GetJsonValue('id').AsText(), 1, MaxStrLen("Project ID"));
                            "Project Name" := CopyStr(jSONMethods.GetJsonValue('name').AsText(), 1, MaxStrLen("Project Name"));
                        end;
                    end;
                end;
        end;

        "Import Header ID" := importHeader.GetLastEntryNo();
    end;

}