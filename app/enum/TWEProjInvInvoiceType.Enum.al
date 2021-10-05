/// <summary>
/// Enum TWE Invoice Type (ID 50001).
/// </summary>
enum 50001 "TWE Proj. Inv. Invoice Type"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Item)
    {
        Caption = 'Item';
    }
    value(2; "G/L Account")
    {
        Caption = 'G/L Account';
    }
    value(3; Resource)
    {
        Caption = 'Ressource';
    }

}
