function cfg = project_config()
% PROJECT_CONFIG centralizes all workspace paths and placeholders.
%   Use this helper to refer to data and results folders without
%   embedding any personal or machine-specific paths in the analysis scripts.

    persistent cfg_cache;
    if ~isempty(cfg_cache)
        cfg = cfg_cache;
        return;
    end

    repo_root = fileparts(mfilename('fullpath'));
    cfg.repo_root = repo_root;

    % Add src to path
    cfg.project_main_scripts = resolve_path('PUP_PROJECT_SCRIPTS', fullfile(repo_root, 'src'));
    addpath(cfg.project_main_scripts);

    % Data directories
    cfg.data.raw = resolve_path('PUP_DATA_RAW', fullfile(repo_root, 'data', 'raw'));
    cfg.data.processed = resolve_path('PUP_DATA_PROCESSED', fullfile(repo_root, 'data', 'processed'));
    cfg.data.external = resolve_path('PUP_DATA_EXTERNAL', fullfile(repo_root, 'data', 'external'));
    
    % Results directories
    cfg.results.features = ensure_folder(fullfile(repo_root, 'results', 'Extracted_Features_Structs'));
    cfg.results.pupil_features = ensure_folder(fullfile(repo_root, 'results', 'Extracted_PUPfeatures_Structs'));
    cfg.results.correlations = ensure_folder(fullfile(repo_root, 'results', 'Correlations_Files'));
    cfg.results.figures = ensure_folder(fullfile(repo_root, 'results', 'figures'));
    cfg.results.processed = ensure_folder(fullfile(repo_root, 'results', 'Processed'));
    
    % Logs directory
    cfg.logs = ensure_folder(fullfile(repo_root, 'logs'));

    % Specific data paths
    cfg.data.ecg = ensure_folder(fullfile(cfg.data.raw, 'rr-data', 'Niazy_aux_dataset'));
    cfg.data.pupil_processed = ensure_folder(fullfile(cfg.data.processed, 'Study 1'));
    
    % Configuration files
    cfg.files.orders_hrv = fullfile(cfg.data.external, 'orders_id_sub_hrv_aux_dataset.mat');
    cfg.files.orders_pupil = fullfile(cfg.data.external, 'orders_id_sub_0004_aux_dataset.mat');
    cfg.files.database_pupil = fullfile(cfg.data.external, 'database_pupil_ECG.mat');
    cfg.files.bands_info = fullfile(cfg.results.correlations, 'bands_info.mat');
    cfg.files.pup_correlation = fullfile(cfg.results.correlations, 'PUP_global_correlation_xcorr_type_3_aux_dataset.mat');

    cfg_cache = cfg;
end

function path = resolve_path(env_name, default_path)
    % If env_name is set, prefer it. Otherwise build the fallback and prepare it.
    candidate = getenv(env_name);
    if ~isempty(candidate)
        path = candidate;
    else
        path = default_path;
        ensure_folder(path);
    end
end

function path = ensure_folder(path)
    % Create directory if it doesn't exist
    if ~exist(path, 'dir')
        mkdir(path);
    end
end
