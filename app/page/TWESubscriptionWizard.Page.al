page 50000 "TWE AssistedSetupWizard"
{
    PageType = NavigatePage;
    SourceTable = '';
    SourceTableTemporary = true;
    Caption = 'Assisted Setup';

    layout
    {
        area(Content)
        {
            group(BannerStandard)
            {
                Editable = false;
                Visible = TopBannerVisible and (CurrentStep < 4);
                field(MediaResourcesStandard; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
            }
            group(BannerDone)
            {
                Editable = false;
                Visible = TopBannerVisible and (CurrentStep = 4);
                field(MediaResourcesDone; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
            }

            group(Step1)
            {
                Visible = (CurrentStep = 0);
                Caption = 'Welcome to your <AppName> Setup.';
                InstructionalText = 'You have successfully installed <AppName> extension. Please follow the instruction on the next pages ....';
            }

            group(Step2)
            {
                Visible = (CurrentStep = 1);
                group(FirstFillingPage)
                {
                    InstructionalText = 'Please fill the first page information.';
                    group(FirstFillingPageGroup)
                    {
                        ShowCaption = false;
                        group(AppsPart)
                        {
                            ShowCaption = false;
                            part(Pagepart; "TWE Subpart")
                            {
                                ApplicationArea = All;
                            }
                        }
                    }
                }
            }

            group(Step3)
            {
                Visible = (CurrentStep = 2);
                group(SecondFillingPage)
                {
                    Caption = 'Second Filling Page';
                    InstructionalText = 'Please give us all your money';
                    field(Name; rec.Name)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Customer Name';
                    }
                }
            }

            group(StepX)
            {
                Visible = (CurrentStep = 5);
                group(FinishPage)
                {
                    Caption = 'All done';
                    InstructionalText = 'Click on Finish to exit the setup and save the data.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionBack)
            {
                ApplicationArea = All;
                Caption = 'Back';
                Enabled = ActionBackAllowed;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    TakeStep(-1);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = ActionNextAllowed;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    TakeStep(1);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                Enabled = ActionFinishAllowed;
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                begin
                    Finish();
                end;
            }
        }
    }

    var
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
        MediaResourcesStandard: Record "Media Resources";
        MediaResourcesDone: Record "Media Resources";
        CurrentStep: Integer;
        ActionBackAllowed: Boolean;
        ActionNextAllowed: Boolean;
        ActionFinishAllowed: Boolean;
        TopBannerVisible: Boolean;

    trigger OnInit()
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage()
    begin
        CurrentStep := 1;
        SetControls();
    end;

    local procedure SetControls()
    begin
        ActionBackAllowed := CurrentStep > 1;
        ActionNextAllowed := (CurrentStep < X);
        ActionFinishAllowed := (CurrentStep > (X - 1));
    end;

    local procedure TakeStep(Step: Integer)
    begin
        CurrentStep += Step;
        SetControls();
    end;

    local procedure Finish()
    begin
        StoreRecordVar();
        CurrPage.Close();
    end;

    local procedure StoreRecordVar();
    var
        RecordVar: Record "SourceTableRecord";
    begin
        if not RecordVar.Get() then begin
            RecordVar.Init();
            RecordVar.Insert();
        end;

        RecordVar.TransferFields(Rec, false);
        RecordVar.Modify(true);
    end;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(CurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(CurrentClientType()))
        then
            if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
               MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;
}