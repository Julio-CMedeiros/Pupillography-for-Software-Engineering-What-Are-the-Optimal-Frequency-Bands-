% ***********************************************************************
% Pupillography for Software Engineering: Frequency Band Analysis
% Authors: Ricardo Couceiro, Julio Medeiros, Andre Bernardes
% Description: This script preprocesses ECG and eye-tracking data, 
%              performs HRV analysis, and extracts features.
% ***********************************************************************


clear all
close all
clc

%%
mfilename
%%
current_file_path = matlab.desktop.editor.getActiveFilename;
current_file = [mfilename '.m'];
main_path = current_file_path(1:end-length(current_file));

addpath(genpath(main_path));

main_path = current_file_path(1:end-length(current_file));
processed_ecg_data_path = [main_path 'Datasets/rr-data/Niazy/'];
processed_eyet_data_path = [main_path 'Datasets/eyet-data/'];

load('labels_images_lib.mat')
load('study1_files_names.mat')

load('D:\DesiredPath\orders_id_sub_hrv.mat')

% Mais para a frente será útil automatica -> ou seja dá para fazer de forma
% diferente isto, mas assim poupo tempo de run do programa
excluded_list_j = [2, 27, 32, 33, 40, 43, 53, 59, 61, 63, 75, 80]; % Runs that don´t have at least 180 secs



for j=1:length(study1_files_names)
%j=1;
    disp(['Processing data from: ' num2str(study1_files_names{j,3}) ' | Subject ID: ' num2str(study1_files_names{j,1}) ' | Run ID: ' num2str(study1_files_names{j,2})]);

    if any(excluded_list_j(:) == j)
        continue;
    end
    %% Set the names of the variables and files to load
    run_number = study1_files_names{j,2};
    subject_id = study1_files_names{j,1};
    folder_name = study1_files_names{j,3};
    
    processed_ecg_file_name = [folder_name '_run0' num2str(run_number) '_GA_ANC0_factor2_win21_re1000hz_QRS.mat'];
    %keyboard;
    if ~isfile([processed_ecg_data_path processed_ecg_file_name])
        warning('Processed ECG file were not found!!!');
        continue;
    end
    
    % Load the data from 1 run from a patient
    % struct -> ECG
    processed_ECG_data = load([processed_ecg_data_path processed_ecg_file_name]);
    processed_ECG_data = processed_ECG_data.ECG;
    
    
    processed_eyet_file_name = ['p_eyedata_study1_s' num2str(subject_id) '_r' num2str(run_number) '.mat'];
    
    if ~isfile([processed_eyet_data_path processed_eyet_file_name])
        warning('Processed eyetracker file were not found!!!');
        continue;
    end

    load([processed_eyet_data_path processed_eyet_file_name]);
    
    %% HRV Analysis

    %new_ecg_fs = 250; % Algum motivo para 250 -> até agr ainda não usei

    ecg_fs = processed_ECG_data.srate; % Sample Frequency do ECG
    ecg_data = processed_ECG_data.data; % Dados
    ecg_time = processed_ECG_data.times/ecg_fs; % Para ficar em segundos


    %% get data from ECG structure

    events = reshape(struct2cell(processed_ECG_data.event),3,[])'; % events to cell array
    eeg_data.events = events;
    indexes_events.ind_qrs = find(strcmp(events(:,1),'qrs')); % Indices correspondentes aos QRS no events

    times_events.qrs_time = cell2mat(events(indexes_events.ind_qrs,2)); % Valores onde ocorrem os QRS na Data
    %qrs_time = qrs_samples; % já são valores (processed_ECG_data.times(qrs_samples)'/ecg_fs;) 

    % Mesma lógica que para os QRS mas para o 'keypad5'
    % Qual o significado físico de 'keypad5'?
    indexes_events.ind_keypad5 = find(strcmp(events(:,1),'keypad5'));
    indexes_events.ind_keypad5_samples = cell2mat(events(indexes_events.ind_keypad5,2));
    times_events.time_keypad = indexes_events.ind_keypad5_samples/ecg_fs;                                          

    % 99- Run start
    eeg_data.time_start_run = [];
    indexes_events.ind_start_run = find(strcmp(events(:,1),'99'));
    eeg_data.sample_start_run = cell2mat(events(indexes_events.ind_start_run,2));
    eeg_data.time_start_run = eeg_data.sample_start_run/ecg_fs; % em segundos

    % 1- Code with bugs
    times_events.time_code = [];
    indexes_events.ind_code = find(strcmp(events(:,1),'1'));
    eeg_data.sample_code = cell2mat(events(indexes_events.ind_code,2));
    eeg_data.time_code = eeg_data.sample_code/ecg_fs; % em segundos

    % 2- Neutral Code
    times_events.time_neutral = [];
    indexes_events.ind_neutral = find(strcmp(events(:,1),'2'));
    eeg_data.sample_neutral = cell2mat(events(indexes_events.ind_neutral,2));
    eeg_data.time_neutral = eeg_data.sample_neutral/ecg_fs;

    % 3- Text
    times_events.time_text = [];
    indexes_events.ind_text = find(strcmp(events(:,1),'3'));
    eeg_data.sample_text = cell2mat(events(indexes_events.ind_text,2));
    eeg_data.time_text = eeg_data.sample_text/ecg_fs;

    other_events = events(:,1:2);
    other_events([indexes_events.ind_qrs(:);indexes_events.ind_keypad5],:) = [];

    if isempty(eeg_data.time_start_run) 
        % Assumimos que começou 30 seg antes do primeiro "trigger" caso não seja encontrado
        eeg_data.time_start_run = cell2mat(events(min([indexes_events.ind_text indexes_events.ind_neutral indexes_events.ind_code]),2))/ecg_fs-30;
    end
    disp([eeg_data.time_start_run et.states_time_boundaries(1,2)])

    times_events.time_other_events = cell2mat(other_events(:,2))/ecg_fs;
    times_events.time_other_events = times_events.time_other_events-eeg_data.time_start_run; 
    % este desconto que estamos a fazer aqui do time_start_run, pq não fazemos
    % nos outros parametros?

    % 11- Bug confirmed
    times_events.time_bug = [];
    indexes_events.ind_bug = find(strcmp(other_events(:,1),'11'));
    times_events.time_bug = times_events.time_other_events(indexes_events.ind_bug);

    % 12- Clear bug
    times_events.time_clear = [];
    indexes_events.ind_clear = find(strcmp(other_events(:,1),'12'));
    times_events.time_clear = times_events.time_other_events(indexes_events.ind_clear);

    % 13- Linha
    times_events.time_line = [];
    indexes_events.ind_line = find(strcmp(other_events(:,1),'13'));
    times_events.time_line = times_events.time_other_events(indexes_events.ind_line);

    % 14- Pagina
    times_events.time_page = [];
    indexes_events.ind_page = find(strcmp(other_events(:,1),'14'));
    times_events.time_page = times_events.time_other_events(indexes_events.ind_page);

    % 15- Fixation cross
    times_events.time_fix = [];
    indexes_events.ind_fix = find(strcmp(other_events(:,1),'15')); %cruz
    times_events.time_fix = times_events.time_other_events(indexes_events.ind_fix);

    ecg_time = ecg_time-eeg_data.time_start_run; % descontar o tempo que demorou a começar a run


    %% Find R-peaks locations 

    %já feito, os R-peaks correspondem ao QRS que vão ser os dRp_time

    dRp_time = times_events.qrs_time/ecg_fs; % =>  Passei para segundos
    dRp_time = unique(dRp_time);

    %% Remove outliers
    dRp = diff(dRp_time); % Calcula a diferença entre os pontos adjacentes (NN)
    dRp = [dRp(1);dRp]; % Assumimos o 1 como igual ao 2

    [ind_in,ind_out] = RemoveOutliersPupilD(dRp,3,0);

    dRp = interp1(dRp_time(ind_in),dRp(ind_in),dRp_time,'linear'); 
    % -> interpolação para ficar no formato original (tamnho e espaçamento entre pontos, evitar "buracos")

    %% Resample RR data
    % estávamos a ir 1/8 de ms em 1/8 de ms -> passei tudo para segundos
    new_dRp.fs = 8; % guidelines*

    new_dRp.time_resamp = dRp_time(1):1/new_dRp.fs:dRp_time(end); % usar como time
    new_dRp.resamp = interp1(dRp_time,dRp,new_dRp.time_resamp,'spline'); % usar como data
    % interp1(x -> tempos, values, new_x -> new_times, 'método')

    % ecgLowPass
    %par=0.25;
    ord=fix(0.25*length(new_dRp.resamp)); % ord=fix(par*length(new_dRp_resamp))
    %fix arredonda para baixo (= floor)
    new_dRp.resamp= ecgLowPass(new_dRp.resamp,new_dRp.fs,1,1,ord); 

    %% Plot RR signals (org and resamp)
    %%figure(2)
%     clf
%     hold on
%     plot(new_dRp.time_resamp,new_dRp.resamp)
%     plot(dRp_time,dRp,'r')


    %% Get data sections 
    % Alguns dos parametros aqui estão vazios
    disp('*******Getting time series corresponding to rest and code*****')

    offset_start=10; %% offset for trigger 2,4,5 -> start/end x secods after/before the trigger
    offset_end = 1;

    % Ir buscar os triggers para conseguir dividir em neutro, rest e code
    resamp_states = GetTriggersTimesSamples(new_dRp.time_resamp,et.states_time_boundaries,offset_start,offset_end);

    new_dRp.resamp_samples_rest = resamp_states.text.samples;
    new_dRp.resamp_time_rest = resamp_states.text.time;
    new_dRp.resamp_data_rest = new_dRp.resamp(resamp_states.text.samples);

    new_dRp.resamp_samples_neutral = resamp_states.neutral.samples;
    new_dRp.resamp_time_neutral = resamp_states.neutral.time;
    new_dRp.resamp_data_neutral = new_dRp.resamp(resamp_states.neutral.samples);

    new_dRp.resamp_samples_code = resamp_states.code.samples;
    new_dRp.resamp_time_code = resamp_states.code.time;
    new_dRp.resamp_data_code = new_dRp.resamp(resamp_states.code.samples);
    
    % Register events duration
    % rest
    try
       info_times.rest.start = resamp_states.text.time(1);
       info_times.rest.end = resamp_states.text.time(length(resamp_states.text.time));
       info_times.rest.duration = info_times.rest.end - info_times.rest.start;
    catch
       info_times.rest.start = "Not Found";
       info_times.rest.end = "Not Found";
       info_times.rest.duration = "Not Found";
    end
    % neutral
    try
        info_times.neutral.start = resamp_states.neutral.time(1);
        info_times.neutral.end = resamp_states.neutral.time(length(resamp_states.neutral.time));
        info_times.neutral.duration = info_times.neutral.end - info_times.neutral.start;
    catch
        info_times.neutral.start = "Not Found";
        info_times.neutral.end = "Not Found";
        info_times.neutral.duration = "Not Found";
    end
    % code
    try
        info_times.code.start = resamp_states.code.time(1);
        info_times.code.end = resamp_states.code.time(length(resamp_states.code.time));
        info_times.code.duration = info_times.code.end - info_times.code.start;
    catch
        info_times.code.start = "Not Found";
        info_times.code.end = "Not Found";
        info_times.code.duration = "Not Found";
    end


    %% Plot resampled data with diferent colors for each state
%     figure(3)
%     clf
%     hold on
%     plot(new_dRp.resamp_time_rest, new_dRp.resamp_data_rest,'.-r')
%     plot(new_dRp.resamp_time_neutral, new_dRp.resamp_data_neutral,'.-g')
%     plot(new_dRp.resamp_time_code, new_dRp.resamp_data_code,'.-b')



    %% Features extraction
%     windows_list = [180, 120, 60, 50, 40, 30, 20, 10];
    windows_list = [180];
    lines_freq = ["psd_time"; "psd_freq"; "psd"; "aT"; "aP"; "RaP"; "pT"; "pP"; "RpP"];
    lines_fd = ["psd_time"; "aT"; "pT"; "aP_VLF"; "aP_LF"; "aP_HF"; "pP_VLF"; "pP_LF"; "pP_HF";"RaP_VLF"; "RaP_LF"; "RaP_HF"; "RpP_VLF"; "RpP_LF"; "RpP_HF"; "aP_LF/HF"; "pP_LF/HF"];
    lines_td = ["T"; "mRR"; "sdnnRR"; "sdsdRR"; "rmssd"; "nn50RR"; "pnn50RR"; "ApEn_value"; "SD1"; "SD2"; "KFD"; "HFD"; "PTM"; "SI"; "TI"; "TINN"];

    
    for i=1 % para 180 secs so
    % for i=1:length(windows_list)
        % ------- Parameter initialization ------
        just_one_value = false; % Para otimizar o programa quando só existe necessidade de calc um valor
        
        type_order = 1; % 1 para sub/run; 2 para sub; 3 para geral
        criteria = 2; % 1 AIC // 2 BIC // 3 MDL
        
%         labels_sub_id = orders_id_sub.labels;
%         container_sub_id = orders_id_sub.container;
%         
%         if type_order==1
%             idx_to_extract = find(labels_sub_id(:,1)==subject_id & labels_sub_id(:,2)==run_number); % Indices of rows with 1 in first column and 2 in second column
%             idx_extracted = container_sub_id(idx_to_extract, criteria); % Extract rows with desired values
%             
%         elseif type_order==2
%             idx_to_extract = find(labels_sub_id(:,1)==subject_id); % Indices of rows with 1 in first column and 2 in second column
%             idx_extracted = container_sub_id(idx_to_extract, criteria); % Extract rows with desired values
%             
%         elseif type_order==3
%             idx_extracted = container_sub_id(:, criteria); % Extract rows with desired values
%             
%         end
%         
%         AA = idx_extracted(:);
% %         median_result = median(AA); % Compute median of the extracted rows
%         median_result = quantile(AA,0.75); % Compute 3rd quartile of the extracted rows
        
%         order = round(median_result);
        order = 20;
        
        typePsd = 0; %% burg
        display = 0; % mudei para 0, 1 aparecem gráficos

        window_secs = windows_list(i);
        window_samp =  window_secs * new_dRp.fs;

        jump_secs = 1;
        jump_samp = floor(jump_secs*new_dRp.fs); % floor - arredondamento para baixo

        freq_vec = 0:0.01:10;
        freq_bands = [0 0.04 0.15 0.4];
        
        %% CODE
    % ------- Features extraction ------
        % --- Domínio da frequência ---
          [global_features_HRV{subject_id,run_number}.code{1, i}, global_features_HRV{subject_id,run_number}.code{2, i},  global_features_HRV{subject_id,run_number}.code{3, i} ...
               , global_features_HRV{subject_id,run_number}.code{4, i}, global_features_HRV{subject_id,run_number}.code{5, i}, global_features_HRV{subject_id,run_number}.code{6, i} ...
               , global_features_HRV{subject_id,run_number}.code{7, i}, global_features_HRV{subject_id,run_number}.code{8, i} ...
               , global_features_HRV{subject_id,run_number}.code{9, i}] = TimeVariant_FreqAnalysis(new_dRp.resamp_time_code, new_dRp.resamp_data_code, new_dRp.fs, typePsd, freq_vec, freq_bands, window_samp, jump_samp, display, false,order);

        % --- reorganize freq dom features struct ---
          global_features_HRV_fd{subject_id,run_number}.code{1, i} = global_features_HRV{subject_id,run_number}.code{1, i};
          global_features_HRV_fd{subject_id,run_number}.code{2, i} = global_features_HRV{subject_id,run_number}.code{4, i};
          global_features_HRV_fd{subject_id,run_number}.code{3, i} = global_features_HRV{subject_id,run_number}.code{7, i};
        
          global_features_HRV_fd{subject_id,run_number}.code{4, i} = global_features_HRV{subject_id,run_number}.code{5, i}(1,:);
          global_features_HRV_fd{subject_id,run_number}.code{5, i} = global_features_HRV{subject_id,run_number}.code{5, i}(2,:);
          global_features_HRV_fd{subject_id,run_number}.code{6, i} = global_features_HRV{subject_id,run_number}.code{5, i}(3,:);
          
          global_features_HRV_fd{subject_id,run_number}.code{7, i} = global_features_HRV{subject_id,run_number}.code{8, i}(1,:);
          global_features_HRV_fd{subject_id,run_number}.code{8, i} = global_features_HRV{subject_id,run_number}.code{8, i}(2,:);
          global_features_HRV_fd{subject_id,run_number}.code{9, i} = global_features_HRV{subject_id,run_number}.code{8, i}(3,:);
          
          global_features_HRV_fd{subject_id,run_number}.code{10, i} = global_features_HRV{subject_id,run_number}.code{6, i}(1,:);
          global_features_HRV_fd{subject_id,run_number}.code{11, i} = global_features_HRV{subject_id,run_number}.code{6, i}(2,:);
          global_features_HRV_fd{subject_id,run_number}.code{12, i} = global_features_HRV{subject_id,run_number}.code{6, i}(3,:);
          
          global_features_HRV_fd{subject_id,run_number}.code{13, i} = global_features_HRV{subject_id,run_number}.code{9, i}(1,:);
          global_features_HRV_fd{subject_id,run_number}.code{14, i} = global_features_HRV{subject_id,run_number}.code{9, i}(2,:);
          global_features_HRV_fd{subject_id,run_number}.code{15, i} = global_features_HRV{subject_id,run_number}.code{9, i}(3,:);
          
         % Acrescentar LF/HF
         global_features_HRV_fd{subject_id,run_number}.code{16, i} = global_features_HRV{subject_id,run_number}.code{5, i}(2,:) ./ global_features_HRV{subject_id,run_number}.code{5, i}(3,:);
         global_features_HRV_fd{subject_id,run_number}.code{17, i} = global_features_HRV{subject_id,run_number}.code{8, i}(2,:) ./ global_features_HRV{subject_id,run_number}.code{8, i}(3,:);
        
         % --- Domínio do Tempo e Domínio não Linear ---
          [global_features_HRV_td{subject_id,run_number}.code{1, i}, global_features_HRV_td{subject_id,run_number}.code{2, i}, global_features_HRV_td{subject_id,run_number}.code{3, i}...
              , global_features_HRV_td{subject_id,run_number}.code{4, i}, global_features_HRV_td{subject_id,run_number}.code{5, i}, global_features_HRV_td{subject_id,run_number}.code{6, i}...
              , global_features_HRV_td{subject_id,run_number}.code{7, i},global_features_HRV_td{subject_id,run_number}.code{8, i},global_features_HRV_td{subject_id,run_number}.code{9, i}...
              , global_features_HRV_td{subject_id,run_number}.code{10, i}, global_features_HRV_td{subject_id,run_number}.code{11, i}, global_features_HRV_td{subject_id,run_number}.code{12, i} ...
              , global_features_HRV_td{subject_id,run_number}.code{13, i}, global_features_HRV_td{subject_id,run_number}.code{14, i}, global_features_HRV_td{subject_id,run_number}.code{15, i} ...
              , global_features_HRV_td{subject_id,run_number}.code{16, i}] = TimeVariant_hrv_TimeAnalysis(new_dRp.resamp_time_code,new_dRp.resamp_data_code*1000,window_samp,jump_samp, window_secs, just_one_value);

        % Descartar primeiros valores - estes são valores de padding, zeros
        % ou NaN
          for feature = 1:length(lines_td)
              try
                  limit_discarted = ceil(window_secs/2);
                  global_features_HRV_td{subject_id,run_number}.code{feature, i}(1:limit_discarted)=[];
              catch
              end
          end
          for feature = 1:length(lines_fd)
              try
                  limit_discarted = ceil(window_secs/2);
                  global_features_HRV_fd{subject_id,run_number}.code{feature, i}(1:limit_discarted)=[];
              catch
              end
          end    
          
          
           %% REST
           if windows_list(i) > info_times.rest.duration
               window_secs = info_times.rest.duration;
               window_samp =  window_secs * new_dRp.fs;
               
               just_one_value = true;
           end
    % ------- Features extraction ------
        % --- Domínio da frequência ---
          [global_features_HRV{subject_id,run_number}.rest{1, i}, global_features_HRV{subject_id,run_number}.rest{2, i},  global_features_HRV{subject_id,run_number}.rest{3, i} ...
               , global_features_HRV{subject_id,run_number}.rest{4, i}, global_features_HRV{subject_id,run_number}.rest{5, i}, global_features_HRV{subject_id,run_number}.rest{6, i} ...
               , global_features_HRV{subject_id,run_number}.rest{7, i}, global_features_HRV{subject_id,run_number}.rest{8, i} ...
               , global_features_HRV{subject_id,run_number}.rest{9, i}] = TimeVariant_FreqAnalysis(new_dRp.resamp_time_rest,new_dRp.resamp_data_rest,new_dRp.fs,typePsd,freq_vec,freq_bands, window_samp,jump_samp,display,just_one_value,order);

        % --- reorganize freq dom features struct ---
          global_features_HRV_fd{subject_id,run_number}.rest{1, i} = global_features_HRV{subject_id,run_number}.rest{1, i};
          global_features_HRV_fd{subject_id,run_number}.rest{2, i} = global_features_HRV{subject_id,run_number}.rest{4, i};
          global_features_HRV_fd{subject_id,run_number}.rest{3, i} = global_features_HRV{subject_id,run_number}.rest{7, i};
        
          global_features_HRV_fd{subject_id,run_number}.rest{4, i} = global_features_HRV{subject_id,run_number}.rest{5, i}(1,:);
          global_features_HRV_fd{subject_id,run_number}.rest{5, i} = global_features_HRV{subject_id,run_number}.rest{5, i}(2,:);
          global_features_HRV_fd{subject_id,run_number}.rest{6, i} = global_features_HRV{subject_id,run_number}.rest{5, i}(3,:);
          
          global_features_HRV_fd{subject_id,run_number}.rest{7, i} = global_features_HRV{subject_id,run_number}.rest{8, i}(1,:);
          global_features_HRV_fd{subject_id,run_number}.rest{8, i} = global_features_HRV{subject_id,run_number}.rest{8, i}(2,:);
          global_features_HRV_fd{subject_id,run_number}.rest{9, i} = global_features_HRV{subject_id,run_number}.rest{8, i}(3,:);
          
          global_features_HRV_fd{subject_id,run_number}.rest{10, i} = global_features_HRV{subject_id,run_number}.rest{6, i}(1,:);
          global_features_HRV_fd{subject_id,run_number}.rest{11, i} = global_features_HRV{subject_id,run_number}.rest{6, i}(2,:);
          global_features_HRV_fd{subject_id,run_number}.rest{12, i} = global_features_HRV{subject_id,run_number}.rest{6, i}(3,:);
          
          global_features_HRV_fd{subject_id,run_number}.rest{13, i} = global_features_HRV{subject_id,run_number}.rest{9, i}(1,:);
          global_features_HRV_fd{subject_id,run_number}.rest{14, i} = global_features_HRV{subject_id,run_number}.rest{9, i}(2,:);
          global_features_HRV_fd{subject_id,run_number}.rest{15, i} = global_features_HRV{subject_id,run_number}.rest{9, i}(3,:);
          
          % Acrescentar LF/HF
          global_features_HRV_fd{subject_id,run_number}.rest{16, i} = global_features_HRV{subject_id,run_number}.rest{5, i}(2,:) ./ global_features_HRV{subject_id,run_number}.rest{5, i}(3,:);
          global_features_HRV_fd{subject_id,run_number}.rest{17, i} = global_features_HRV{subject_id,run_number}.rest{8, i}(2,:) ./ global_features_HRV{subject_id,run_number}.rest{8, i}(3,:);
         
         % --- Domínio do Tempo e Domínio não Linear ---
          [global_features_HRV_td{subject_id,run_number}.rest{1, i}, global_features_HRV_td{subject_id,run_number}.rest{2, i}, global_features_HRV_td{subject_id,run_number}.rest{3, i}...
              , global_features_HRV_td{subject_id,run_number}.rest{4, i}, global_features_HRV_td{subject_id,run_number}.rest{5, i}, global_features_HRV_td{subject_id,run_number}.rest{6, i}...
              , global_features_HRV_td{subject_id,run_number}.rest{7, i},global_features_HRV_td{subject_id,run_number}.rest{8, i},global_features_HRV_td{subject_id,run_number}.rest{9, i}...
              , global_features_HRV_td{subject_id,run_number}.rest{10, i}, global_features_HRV_td{subject_id,run_number}.rest{11, i}, global_features_HRV_td{subject_id,run_number}.rest{12, i} ...
              , global_features_HRV_td{subject_id,run_number}.rest{13, i}, global_features_HRV_td{subject_id,run_number}.rest{14, i}, global_features_HRV_td{subject_id,run_number}.rest{15, i} ...
              , global_features_HRV_td{subject_id,run_number}.rest{16, i}] = TimeVariant_hrv_TimeAnalysis(new_dRp.resamp_time_rest,new_dRp.resamp_data_rest*1000,window_samp,jump_samp, window_secs, just_one_value);

        % Descartar primeiros valores (quando já não é um único valor)
        if just_one_value==false
          for feature = 1:length(lines_td)
              try
                  limit_discarted = ceil(window_secs/2);
                  global_features_HRV_td{subject_id,run_number}.rest{feature, i}(1:limit_discarted)=[];
              catch
              end
          end
          for feature = 1:length(lines_fd)
              try
                  limit_discarted = ceil(window_secs/2);
                  global_features_HRV_fd{subject_id,run_number}.rest{feature, i}(1:limit_discarted)=[];
              catch
              end
          end   
        end
        
        %% Neutral
           % Caso venha alterado do REST temos que garantir que está com o
           % tamanho da janela correto:
           window_secs = windows_list(i);
           window_samp =  window_secs * new_dRp.fs;

           just_one_value = false;
           
           % Situações em que não existe secção neutral (acontece no 12,1 e
           % no 16,1 -> se bem que neste 16,1 nem o usamos
           try
               if strcmp(info_times.neutral.duration,"Not Found")
                   continue;
               end
           catch
           end
           % Agora sim fazer o teste
           if windows_list(i) > info_times.neutral.duration
               window_secs = info_times.neutral.duration;
               window_samp =  window_secs * new_dRp.fs;
               
               just_one_value = true;
           end
    % ------- Features extraction ------
        % --- Domínio da frequência ---
          [global_features_HRV{subject_id,run_number}.neutral{1, i}, global_features_HRV{subject_id,run_number}.neutral{2, i},  global_features_HRV{subject_id,run_number}.neutral{3, i} ...
               , global_features_HRV{subject_id,run_number}.neutral{4, i}, global_features_HRV{subject_id,run_number}.neutral{5, i}, global_features_HRV{subject_id,run_number}.neutral{6, i} ...
               , global_features_HRV{subject_id,run_number}.neutral{7, i}, global_features_HRV{subject_id,run_number}.neutral{8, i} ...
               , global_features_HRV{subject_id,run_number}.neutral{9, i}] = TimeVariant_FreqAnalysis(new_dRp.resamp_time_neutral, new_dRp.resamp_data_neutral, new_dRp.fs, typePsd, freq_vec, freq_bands, window_samp, jump_samp, display, just_one_value,order);

        % --- reorganize freq dom features struct ---
          global_features_HRV_fd{subject_id,run_number}.neutral{1, i} = global_features_HRV{subject_id,run_number}.neutral{1, i};
          global_features_HRV_fd{subject_id,run_number}.neutral{2, i} = global_features_HRV{subject_id,run_number}.neutral{4, i};
          global_features_HRV_fd{subject_id,run_number}.neutral{3, i} = global_features_HRV{subject_id,run_number}.neutral{7, i};
        
          global_features_HRV_fd{subject_id,run_number}.neutral{4, i} = global_features_HRV{subject_id,run_number}.neutral{5, i}(1,:);
          global_features_HRV_fd{subject_id,run_number}.neutral{5, i} = global_features_HRV{subject_id,run_number}.neutral{5, i}(2,:);
          global_features_HRV_fd{subject_id,run_number}.neutral{6, i} = global_features_HRV{subject_id,run_number}.neutral{5, i}(3,:);
          
          global_features_HRV_fd{subject_id,run_number}.neutral{7, i} = global_features_HRV{subject_id,run_number}.neutral{8, i}(1,:);
          global_features_HRV_fd{subject_id,run_number}.neutral{8, i} = global_features_HRV{subject_id,run_number}.neutral{8, i}(2,:);
          global_features_HRV_fd{subject_id,run_number}.neutral{9, i} = global_features_HRV{subject_id,run_number}.neutral{8, i}(3,:);
          
          global_features_HRV_fd{subject_id,run_number}.neutral{10, i} = global_features_HRV{subject_id,run_number}.neutral{6, i}(1,:);
          global_features_HRV_fd{subject_id,run_number}.neutral{11, i} = global_features_HRV{subject_id,run_number}.neutral{6, i}(2,:);
          global_features_HRV_fd{subject_id,run_number}.neutral{12, i} = global_features_HRV{subject_id,run_number}.neutral{6, i}(3,:);
          
          global_features_HRV_fd{subject_id,run_number}.neutral{13, i} = global_features_HRV{subject_id,run_number}.neutral{9, i}(1,:);
          global_features_HRV_fd{subject_id,run_number}.neutral{14, i} = global_features_HRV{subject_id,run_number}.neutral{9, i}(2,:);
          global_features_HRV_fd{subject_id,run_number}.neutral{15, i} = global_features_HRV{subject_id,run_number}.neutral{9, i}(3,:);
          
          % Acrescentar LF/HF
          global_features_HRV_fd{subject_id,run_number}.neutral{16, i} = global_features_HRV{subject_id,run_number}.neutral{5, i}(2,:) ./ global_features_HRV{subject_id,run_number}.neutral{5, i}(3,:);
          global_features_HRV_fd{subject_id,run_number}.neutral{17, i} = global_features_HRV{subject_id,run_number}.neutral{8, i}(2,:) ./ global_features_HRV{subject_id,run_number}.neutral{8, i}(3,:);
         
         % --- Domínio do Tempo e Domínio não Linear ---
          [global_features_HRV_td{subject_id,run_number}.neutral{1, i}, global_features_HRV_td{subject_id,run_number}.neutral{2, i}, global_features_HRV_td{subject_id,run_number}.neutral{3, i}...
              , global_features_HRV_td{subject_id,run_number}.neutral{4, i}, global_features_HRV_td{subject_id,run_number}.neutral{5, i}, global_features_HRV_td{subject_id,run_number}.neutral{6, i}...
              , global_features_HRV_td{subject_id,run_number}.neutral{7, i},global_features_HRV_td{subject_id,run_number}.neutral{8, i},global_features_HRV_td{subject_id,run_number}.neutral{9, i}...
              , global_features_HRV_td{subject_id,run_number}.neutral{10, i}, global_features_HRV_td{subject_id,run_number}.neutral{11, i}, global_features_HRV_td{subject_id,run_number}.neutral{12, i} ...
              , global_features_HRV_td{subject_id,run_number}.neutral{13, i}, global_features_HRV_td{subject_id,run_number}.neutral{14, i}, global_features_HRV_td{subject_id,run_number}.neutral{15, i} ...
              , global_features_HRV_td{subject_id,run_number}.neutral{16, i}] = TimeVariant_hrv_TimeAnalysis(new_dRp.resamp_time_neutral,new_dRp.resamp_data_neutral*1000,window_samp,jump_samp, window_secs, just_one_value);

        % Descartar primeiros valores (quando já não é um único valor)
        if just_one_value==false
          for feature = 1:length(lines_td)
              try
                  limit_discarted = ceil(window_secs/2);
                  global_features_HRV_td{subject_id,run_number}.neutral{feature, i}(1:limit_discarted)=[];
              catch
              end
          end
          for feature = 1:length(lines_fd)
              try
                  limit_discarted = ceil(window_secs/2);
                  global_features_HRV_fd{subject_id,run_number}.neutral{feature, i}(1:limit_discarted)=[];
              catch
              end
          end   
        end
    end

 
    global_features_HRV{subject_id,run_number}.help_window_column_order = windows_list;
    global_features_HRV_fd{subject_id,run_number}.help_window_column_order = windows_list;
    global_features_HRV_td{subject_id,run_number}.help_window_column_order = windows_list;
    
    global_features_HRV{subject_id,run_number}.help_features_line_order = lines_freq;
    global_features_HRV_fd{subject_id,run_number}.help_features_line_order = lines_fd;
    global_features_HRV_td{subject_id,run_number}.help_features_line_order = lines_td;
    
    global_features_HRV{subject_id,run_number}.info_times = info_times;
    global_features_HRV_fd{subject_id,run_number}.info_times = info_times;
    global_features_HRV_td{subject_id,run_number}.info_times = info_times;
  
end

 filename = strcat('global_features_HRV_td.mat');
 save(fullfile('D:\DesiredPath\','Extracted_Features_Structs', filename), 'global_features_HRV_td');
 
 filename = strcat('global_features_HRV.mat');
 save(fullfile('D:\DesiredPath\','Extracted_Features_Structs', filename), 'global_features_HRV');
 
%  filename = strcat('global_features_HRV_fd_try2_quantile_type',num2str(type_order),'.mat');
 filename = strcat('global_features_HRV_fd.mat');
 save(fullfile('D:\DesiredPath\','Extracted_Features_Structs', filename), 'global_features_HRV_fd');
 
