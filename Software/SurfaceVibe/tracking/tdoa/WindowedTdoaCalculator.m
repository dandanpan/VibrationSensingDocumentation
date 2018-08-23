classdef WindowedTdoaCalculator < TdoaCalculator
    %WINDOWEDTDOACALCULATOR a decorator class that adds windowing to TDoA
    %calculation
    
    properties
        calculator
        windowSize
    end
    
    methods
        
        function obj = WindowedTdoaCalculator(calculator, windowSize)
            if nargin < 2
               windowSize = 500; 
            end
            assert(isa(calculator,'TdoaCalculator'), 'Must provide a calculator class!');
            obj.calculator = calculator;
            obj.windowSize = windowSize;
        end
        
        function tdoas = calculate(obj, time, signals)                        
            % generate list of window start indices
            % each window is of size |windowSize|
            % and has an offset of |windowSize/2| from
            % the last window start
            wSize = obj.windowSize;
            startIdxs = 1:(wSize/2):(length(signals)-1);
            
            % remove last 2 indices to make sure we don't go over the 
            % edge of the noise signal
            startIdxs = startIdxs(1:end-2);
            
            % number of windows to process
            n = length(startIdxs);
            
            % number of channels
            sN = size(signals,2);
            
            % expected number of tdoas (n x sN)
            tdoas = zeros(n,sN);
            
            for idx = 1:n
                wStartIdx = startIdxs(idx);
                tWindow = time(wStartIdx:wStartIdx + wSize);
                sWindow = signals(wStartIdx:wStartIdx + wSize, :);
                tdoa = obj.calculator.calculate(tWindow, sWindow);
                tdoas(idx,:) = tdoa;
            end
        end
        
    end
    
end

