classdef TdoaInterpolator < handle
    %TDOAINTERPOLATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numPoints
        calibrationPoints
    end
    
    methods
        
        function obj = TdoaInterpolator()
            obj.numPoints=0;
        end
        
        function addCalibrationPoint(obj, loc, tdoas)
            idx = obj.numPoints+1;
            obj.calibrationPoints{idx} = {loc, tdoas};
            obj.numPoints = idx;
        end
        
        % |dimensions| is an nx2 matrix where each row contains
        % the min and max value for each dimension
        % |resolution| determines the number of points to generate
        % between min and max
        function [Xq,Yq,Vgrid] = interpolate(obj, dimensions, resolution)
            xSpace = linspace(dimensions(1,1), dimensions(1,2), resolution);
            ySpace = linspace(dimensions(2,1), dimensions(2,2), resolution);
            
            [X,Y] = meshgrid(xSpace,ySpace);
            Xq = reshape(X,[],1);
            Yq = reshape(Y,[],1);
            Vgrid = zeros(length(Xq),3); % 3 tdoa pairs
            
            % interpolate for each tdoa pair
            for tdoaPairIdx = 2:4
                % containers for actual values
                x = []; y = []; v = []; 
                for cPointIdx = 1:obj.numPoints
                   calibrationPoint = obj.calibrationPoints{cPointIdx}; 
                   loc = calibrationPoint{1};
                   toas = calibrationPoint{2};
                   nPointCount = size(toas,1);
                   x = [x; loc(1) * ones(nPointCount,1)];
                   y = [y; loc(2) * ones(nPointCount,1)];
                   v = [v; toas(:,tdoaPairIdx)-toas(:,1)];
                end
                
                % interpolate 
                Vq = griddata(x,y,v,Xq,Yq,'v4');
                Vgrid(:,tdoaPairIdx-1) = Vq;
            end
            
        end
        
    end
    
end

