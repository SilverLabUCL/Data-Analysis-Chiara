
[SomaDS, TuftDS, TimeConcat] = VisualizeOnsetTuftVsSoma;

disp('wait for me')

[OnsetSoma, DurationSoma] = OnsetDuration(SomaDS,cursor_info);
figure(gcf); title('Soma')

[OnsetTuft, DurationTuft] = OnsetDuration(TuftDS,cursor_info);
figure(gcf); title('Tuft')

DurationSoma = TimeConcat(OnsetSoma+DurationSoma) - TimeConcat(OnsetSoma);
OnsetSoma = TimeConcat(OnsetSoma);

DurationTuft = TimeConcat(OnsetTuft+DurationTuft) - TimeConcat(OnsetTuft);
OnsetTuft = TimeConcat(OnsetTuft);

save('OnsetTuftSoma4.mat')
