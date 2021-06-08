codeunit 50000 "TWE AssistedSetup Integration"
{
    var
        SetupWizardTxt: Label 'Text displayed on Assisted Setup page';
        BaseAppSetupTitleLbl: Label 'Mayan EDMS';
        BaseAppSetupShortTitleLbl: Label 'ShortTitke of the Setup';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', false, false)]
    local procedure Initialize()
    var
        GuidedExperience: Codeunit "Guided Experience";
        Language: Codeunit Language;
        CurrentGlobalLanguage: Integer;
    begin
        if not GuidedExperience.Exists("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"TWE AssistedSetupWizard") then begin
            CurrentGlobalLanguage := GlobalLanguage;
            GuidedExperience.InsertAssistedSetup(
                BaseAppSetupTitleLbl, BaseAppSetupShortTitleLbl,
                SetupWizardTxt, 5,
                ObjectType::Page, Page::"TWE AssistedSetupWizard",
                "Assisted Setup Group"::Extensions, '', "Video Category"::Uncategorized, '');

            GlobalLanguage(Language.GetDefaultApplicationLanguageId());

            GuidedExperience.AddTranslationForSetupObjectTitle(
                "Guided Experience Type"::"Assisted Setup", ObjectType::Page,
                Page::"TWE AssistedSetupWizard", Language.GetDefaultApplicationLanguageId(),
                SetupWizardTxt);
            GlobalLanguage(CurrentGlobalLanguage);
        end;
    end;
}