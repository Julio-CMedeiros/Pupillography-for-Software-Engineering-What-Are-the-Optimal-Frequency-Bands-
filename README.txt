Main0 - limpeza do ecg, find RR e essas cenas, mais para visualizar, o outro guarda o HRV

Main1 - extraçao de features
		_Features_w10s - contem todas as janelas de 10 em 10 (usado agora)
		_Features - contem apenas as que tinha no inicio do projeto

Main2 - Normalizaçao das features

Main3 - extraçao das transformadas

Main4 - arranjar o dataset e colocar labels
		_join_all_withLabel - coloca logo as labels e os IDs necessarios na classificaçao (usado agora - para classificacao)
		_join_all - junta todos sem colocar IDs (usado agora - para selecao de features)

Main5 - seleçao de features (Não usados - selection no proprio modelo em python)
		_feature_selection - Relieff 
		_feature_selection_study_180s - Relieff e KW para os 180s 
		_feature_selection_study_new_version - KW para todos 


TimeVariants -> Chamados no main1

get e geat -> Chamados no main3

degradation_analysis e Bland_Altman_plots-> Análise das janelas temporais 