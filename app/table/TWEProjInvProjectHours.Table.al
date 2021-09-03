/// <summary>
/// Table TWE Project Hours (ID 70704956).
/// </summary>
table 70704956 "TWE Proj. Inv. Project Hours"
{
    DataClassification = CustomerContent;
    Caption = 'Project Invoice Project Hours';

    fields
    {
        field(1; ID; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'ID';
            Editable = false;
        }
        field(2; "Project ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Project ID';
            Editable = false;
        }
        field(5; "Ticket ID"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Ticket ID';
            Editable = false;
        }
        field(6; "Ticket Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Ticket Name';
            Editable = false;
        }
        field(7; "Work Description"; Text[150])
        {
            DataClassification = CustomerContent;
            Caption = 'Work Description';
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
        field(20; Invoiced; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Invoiced';
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