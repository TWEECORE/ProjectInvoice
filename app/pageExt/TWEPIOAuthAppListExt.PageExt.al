pageextension 50001 "TWE PI OAuth AppList Ext." extends "TWE OAuth 2.0 Applications"
{
    layout
    {
        // Adding a new control field 'ShoeSize' in the group 'General'
        addlast(content)
        {
            field("TWE Proj. Inv. Endpoint"; rec."TWE Proj. Inv. Endpoint")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the endpoint used to gain data from a Project Mgt. System';
            }
            field("TWE Timetracking Endpoint"; rec."TWE PI Timetracking Endpoint")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the endpoint used to gain timetracking data from a Project Mgt. System';
            }
        }
    }
}
