table 70704953 "TWE Proj. Inv. Import Line"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; ID; Code[100])
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
        }
        field(2; "Import Header ID"; Integer)
        {
            Caption = 'Import Header ID';
            DataClassification = CustomerContent;
        }
        field(5; "Project ID"; Text[150])
        {
            Caption = 'Project ID';
            DataClassification = CustomerContent;
        }
        field(6; "Project Name"; Text[150])
        {
            Caption = 'Project Name';
            DataClassification = CustomerContent;
        }
        field(7; "Project Description"; Text[150])
        {
            Caption = 'Project Description';
            DataClassification = CustomerContent;
        }
        field(10; "Ticket No."; Text[100])
        {
            Caption = 'Ticket No.';
            DataClassification = CustomerContent;
        }
        field(11; "Ticket Name"; Text[100])
        {
            Caption = 'Ticket Name';
            DataClassification = CustomerContent;
        }
        field(12; "Ticket Status"; Text[100])
        {
            Caption = 'Ticket Status';
            DataClassification = CustomerContent;
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