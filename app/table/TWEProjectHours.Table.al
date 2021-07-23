table 70704956 "TWE Project Hours"
{
    DataClassification = CustomerContent;
    Caption = 'Project Hours';

    fields
    {
        field(1; ID; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'ID';
            Editable = false;
        }
        field(2; "Project ID"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Project ID';
            Editable = false;
        }
        field(5; "Ticket No."; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Ticket No.';
            Editable = false;
        }
        field(10; Hours; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Hours';
        }
        field(15; Agent; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Agent';
            Editable = false;
        }
    }

    keys
    {
        key(PK; ID)
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

}