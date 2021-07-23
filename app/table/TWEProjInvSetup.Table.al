table 70704950 "TWE Proj. Inv. Setup"
{
    Caption = 'PI Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ID; Integer)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "G/L Account"; Code[20])
        {
            Caption = 'G/L Account';
            DataClassification = AccountData;
            TableRelation = "G/L Account"."No.";
        }
        field(100; "No. Series for Import"; Code[20])
        {
            Caption = 'No. Series for Import';
            DataClassification = CustomerContent;
            TableRelation = "No. Series".Code;
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
