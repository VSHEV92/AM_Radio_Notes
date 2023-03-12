
%% скрипт для формирования модулированных записей

clc; clear; close all;

FramesNumber = 1000;    % число обрабатываемых пачек данных
AudioFrameSize = 1000;  % количество отсчетов аудиофайла, получаемых за один раз
RateRatio = 10;         % коэффициент увеличения частоты дискретизации
Amp = 0.1;              % коэффициент усиления перед записью в файл
Ac = 2;                 % амплитуда несущей
Fc = 60e3;              % частота несущей
ModType = "DSB-TC";     % вид модуляции

InputFile = 'wav/Audio_Source.wav';     % входной файл
OutputFile = 'wav/Audio_DSB_TC.wav';     % выходной файл

% объект для считываения отсчетов аудиофайла
AudioReader = dsp.AudioFileReader(...
    InputFile, ...
    'SamplesPerFrame',AudioFrameSize...
    );

% дополнительные расчеты
AudioFs = AudioReader.SampleRate;               % получаем частоту дискретизации аудиосообщения
SignalFs = AudioFs * RateRatio;                 % частота дискретизации модулированного сигнала
SignalFrameSize = AudioFrameSize * RateRatio;   % количество отсчетов Ам-сигнала, получаемых за один раз

% объект для записи отсчетов модулированного сигнала
AudioWriter = dsp.AudioFileWriter(...
   OutputFile, ...
   'SampleRate', SignalFs ...
   );

% генератор несущей
Carrier = dsp.SineWave(...
    'SampleRate', SignalFs,...
    'SamplesPerFrame', SignalFrameSize,...
    'Frequency', [Fc Fc],...
    'PhaseOffset', [pi/2 0], ...
    'Amplitude', [Ac Ac]);

% интерполятор 
Upsampler = dsp.SampleRateConverter(...
    'Bandwidth', 40e3, ...
    'InputSampleRate',AudioFs, ...
    'OutputSampleRate', SignalFs ...
    );

% запуск симуляции
for i = 1:FramesNumber
    % считывание отсчетов аудиосообщения и выделение одного канала из
    % стерео сигнала
    AudioData = AudioReader();
    AudioData = AudioData(:,1);

    % увеличение частоты дискретизации аудиосообщения
    MessageData = Upsampler(AudioData);

    % получение отсчетов несущей
    CarrierWave = Carrier();
    CosWave = CarrierWave(:,1);
    SinWave = CarrierWave(:,2);

    % амплитудная модуляция
    switch ModType
        case "DSB-TC"
            AmInphase = (Ac + MessageData) .* CosWave;
            AmQuadrature = (Ac + MessageData) .* SinWave;
        case "DSB-SC"
            AmInphase = MessageData .* CosWave;
            AmQuadrature = MessageData .* SinWave;
        otherwise
            error('Unexpected modulation type.')
    end

    % ослабление сигнала перед записью в файл
    AmSignal = Amp * [AmInphase AmQuadrature];
    
    % запись данных в файл
    AudioWriter(AmSignal);
end

% закрытие файлов
release(AudioReader);
release(AudioWriter);