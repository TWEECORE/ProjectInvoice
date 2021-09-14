/// <summary>
/// TableExtension TWE OAuth App. Extension (ID 70704950) extends Record TWE OAuth 2.0 Application.
/// </summary>
tableextension 70704950 "TWE PI OAuth App. Extension" extends "TWE OAuth 2.0 Application"
{
    fields
    {
        field(70704950; "TWE Is Project Mgt. System"; Boolean)
        {
            Caption = 'Is Project Mgt. System';
            DataClassification = CustomerContent;
        }
        field(70704951; "TWE Project Mgt. System"; Enum "TWE Project Mgt. System")
        {
            Caption = 'Project Mgt. System';
            DataClassification = CustomerContent;
        }
        field(70704952; "TWE Proj. Inv. Endpoint"; Text[150])
        {
            Caption = 'Endpoint';
            DataClassification = CustomerContent;
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
        }
    }
}
