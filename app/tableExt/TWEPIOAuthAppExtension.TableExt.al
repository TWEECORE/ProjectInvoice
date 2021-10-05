/// <summary>
/// TableExtension TWE OAuth App. Extension (ID 50000) extends Record TWE OAuth 2.0 Application.
/// </summary>
tableextension 50000 "TWE PI OAuth App. Extension" extends "TWE OAuth 2.0 Application"
{
    fields
    {
        field(50000; "TWE Is Project Mgt. System"; Boolean)
        {
            Caption = 'Is Project Mgt. System';
            DataClassification = CustomerContent;
        }
        field(70704951; "TWE Project Mgt. System"; Enum "TWE Project Mgt. System")
        {
            Caption = 'Project Mgt. System';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "TWE Project Mgt. System" = "TWE Project Mgt. System"::"JIRA Tempo" then
                    Validate("TWE PI Timetracking Endpoint", TWEGetTempoTimesheetEndpoint())
                else
                    if "TWE PI Timetracking Endpoint" <> '' then
                        Validate("TWE PI Timetracking Endpoint", '');
            end;
        }
        field(70704952; "TWE Proj. Inv. Endpoint"; Text[150])
        {
            Caption = 'Endpoint';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "TWE Proj. Inv. Endpoint".EndsWith('/') then
                    "TWE Proj. Inv. Endpoint" := "TWE Proj. Inv. Endpoint".Remove("TWE Proj. Inv. Endpoint".LastIndexOf('/'));
            end;
        }
        field(70704953; "TWE Use Permanent Token"; Boolean)
        {
            Caption = 'Use Permanent Token';
            DataClassification = CustomerContent;
        }
        field(70704954; "TWE Proj. Inv. PermToken"; Text[150])
        {
            Caption = 'Permanent Token';
            DataClassification = CustomerContent;
        }
        field(70704955; "TWE PI Timetracking PermToken"; Text[150])
        {
            Caption = 'Timetracking Permanent Token';
            DataClassification = CustomerContent;
        }
        field(70704956; "TWE PI Timetracking Endpoint"; Text[150])
        {
            Caption = 'Timetracking Endpoint';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "TWE PI Timetracking Endpoint".EndsWith('/') then
                    "TWE PI Timetracking Endpoint" := "TWE PI Timetracking Endpoint".Remove("TWE PI Timetracking Endpoint".LastIndexOf('/'));
            end;
        }
    }

    local procedure TWEGetTempoTimesheetEndpoint(): Text
    begin
        exit(TempoTimeSheetEndpointLbl);
    end;

    var
        TempoTimeSheetEndpointLbl: Label 'https://api.tempo.io';
}
