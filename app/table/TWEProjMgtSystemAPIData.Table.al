table 70704951 "TWE Proj. Mgt. System API Data"
{
    DataClassification = CustomerContent;
    Caption = 'Proj. Mgt. System API Data';

    fields
    {
        field(1; ID; Integer)
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; "System Name"; Enum "TWE Project Mgt. System")
        {
            Caption = 'System Name';
            DataClassification = CustomerContent;
        }
        field(5; "Authentication Type"; Enum "TWE API Authentication Type")
        {
            Caption = 'Authentication Type';
            DataClassification = CustomerContent;
        }
        field(10; "API URI"; Text[150])
        {
            Caption = 'API URI';
            DataClassification = CustomerContent;
        }
        field(15; "API Key"; Text[150])
        {
            Caption = 'API Key';
            DataClassification = CustomerContent;
        }
        field(20; "API Access Token"; Text[150])
        {
            Caption = 'API Access Token';
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