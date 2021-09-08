/// <summary>
/// TableExtension TWE OAuth App. Extension (ID 70704950) extends Record TWE OAuth 2.0 Application.
/// </summary>
tableextension 70704950 "TWE PI OAuth App. Extension" extends "TWE OAuth 2.0 Application"
{
    fields
    {
        field(70704950; "TWE Use Project Mgt. System"; Boolean)
        {
            Caption = 'Use Project Mgt. System';
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
    }

    /// <summary>
    /// TWESetProjMgtSystemVisible.
    /// </summary>
    /// <param name="Visble">Boolean.</param>
    procedure TWESetProjMgtSystemVisible(Visble: Boolean)
    begin
        TWEProjMgtSystemVisible := Visble;
    end;

    /// <summary>
    /// TWEGetProjMgtSystemVisible.
    /// </summary>
    /// <returns>Return value of type Boolean.</returns>
    procedure TWEGetProjMgtSystemVisible(): Boolean
    begin
        exit(TWEProjMgtSystemVisible);
    end;

    /// <summary>
    /// TWESetPermTokenVisible.
    /// </summary>
    /// <param name="Visble">Boolean.</param>
    procedure TWESetPermTokenVisible(Visble: Boolean)
    begin
        TWEPermTokenVisible := Visble;
    end;

    /// <summary>
    /// TWEGetPermTokenVisible.
    /// </summary>
    /// <returns>Return value of type Boolean.</returns>
    procedure TWEGetPermTokenVisible(): Boolean
    begin
        exit(TWEPermTokenVisible);
    end;

    var
        TWEProjMgtSystemVisible: Boolean;
        TWEPermTokenVisible: Boolean;
}
