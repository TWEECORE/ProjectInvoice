table 70704955 "TWE Project Ticket"
{
    DataClassification = CustomerContent;
    Caption = 'Project Ticket';

    fields
    {
        field(1; "Ticket No."; Code[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Ticket No.';
            Editable = false;
        }
        field(2; "Project ID"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Project ID';
            Editable = false;
        }
        field(3; "Ticket Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Ticket Name';
            Editable = false;
        }
        field(5; "Ticket Status"; Enum "TWE Proj. Ticket Status")
        {
            DataClassification = CustomerContent;
            Caption = 'Ticket Status';
            Editable = false;
        }
        field(10; "Total Hours"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Total Hours';
        }
    }

    keys
    {
        key(PK; "Ticket No.")
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
        projectHours: Record "TWE Project Hours";
    begin
        projectHours.SetRange("Ticket No.", "Ticket No.");
        if projectHours.FindSet() then
            projectHours.DeleteAll(true);
    end;

    trigger OnRename()
    begin

    end;

}