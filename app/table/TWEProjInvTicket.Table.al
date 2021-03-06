/// <summary>
/// Table TWE Project Ticket (ID 50005).
/// </summary>
table 50005 "TWE Proj. Inv. Ticket"
{
    DataClassification = CustomerContent;
    Caption = 'Project Invoice Project Ticket';

    fields
    {
        field(1; "No."; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Ticket No.';
            Editable = false;
        }
        field(2; "Project ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Project ID';
            Editable = false;
        }
        field(3; "Ticket Name"; Text[150])
        {
            DataClassification = CustomerContent;
            Caption = 'Ticket Name';
            Editable = false;
        }
        field(10; "Total Hours"; Decimal)
        {
            Caption = 'Total Hours';
            FieldClass = FlowField;
            Editable = false;
            DecimalPlaces = 2;

            CalcFormula = sum("TWE Proj. Inv. Project Hours".Hours where("Ticket ID" = field("No.")));
        }
        field(15; "Created At"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Created At';
        }
        field(20; "Created from"; Text[50])
        {
            Caption = 'Created from';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(25; "Project Mgt. System"; Enum "TWE Project Mgt. System")
        {
            Caption = 'Project Mgt. System';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.")
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
    var
        projectHours: Record "TWE Proj. Inv. Project Hours";
    begin
        projectHours.SetRange("Ticket ID", "No.");
        if projectHours.FindSet() then
            projectHours.DeleteAll(true);
    end;

    trigger OnRename()
    begin

    end;
}
