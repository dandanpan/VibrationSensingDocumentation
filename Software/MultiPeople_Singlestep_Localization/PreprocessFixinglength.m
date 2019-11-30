%% preproccessing of the data:  cut the cell data to fixed length and form the matrix []*2*8 for convenient

function data = PreprocessFixinglength(raw_data,channel)

wrong_channel=[];
fixed_length=1e9;
for i=1:channel
        onechannel_length=length(raw_data{i});
        if( onechannel_length<fixed_length)
            fixed_length=onechannel_length;
        end      
end

data=zeros(fixed_length,2,channel);
for i=1:channel
    data(:,:,i)=raw_data{i}(1:fixed_length,:);
    data(:,1,i)=(data(:,1,i)-data(1,1,i))/(1e6);  % get the time unit be second
end
