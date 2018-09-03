function output = cleanNames(a,data)

% output = zeros(50,4);
% for i = 1:numel(data)   
%     strNumber = data{i}(16:end-1);
%     C = strsplit(strNumber, '&');
%     for j = 1:4
%         output(i, j) = str2double(C{j});
%     end
% end

output = cell(a, 1);
for i = 1:numel(data)   
    strNumber = data{i}(16:end-1);
    output{i, 1} = strNumber;
end



end