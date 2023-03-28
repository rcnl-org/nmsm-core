function NameLevelStuct = unfold(SC,varargin)
%UNFOLD Unfolds a structure.
%   UNFOLD(SC) displays the content of a variable. If SC is a structure it
%   recursively shows the name of SC and the fieldnames of SC and their
%   contents. If SC is a cell arraythe contents of each cell are displayed.
%   It uses the caller's workspace variable name as the name of SC. 
%   UNFOLD(SC,NAME) uses NAME as the name of SC.
%   UNFOLD(SC,SHOW) If SHOW is false only the fieldnames and their sizes
%   are  shown, if SHOW is true the contents are shown also.
%   UNFOLD(SC,NAME,SHOW)

%R.F. Tap
%15-6-2005, 7-12-2005, 5-1-2006, 3-4-2006
%Modified to output NameLevelStruct instead of displaying fieldnames by M.Vega 5-4-2022

switch nargin
    case 1
        Name = inputname(1);
        show = true;
    case 2
        if islogical(varargin{1})
            Name = inputname(1);
            show = varargin{1};
        elseif ischar(varargin{1})
            Name = varargin{1};
            show = true;
        end
        NameLevelStuct = {Name '0'};
    case 3
        if ischar(varargin{1})
            if islogical(varargin{2})
                Name = varargin{1};
                show = varargin{2};
            end
        end
    case 4
        if ischar(varargin{1})
            if islogical(varargin{2})
                Name = varargin{1};
                show = varargin{2};
                NameLevelStuct = varargin{3};
            end
        end
end

show = false;

if isstruct(SC)
    %number of elements to be displayed
    NS = numel(SC);
    hmax = min(1,NS);
    %recursively display structure including fieldnames
    for h=1:hmax
        F = fieldnames(SC(h));
        NF = length(F);
        for i=1:NF
            Namei = [Name '.' F{i}];
            if isstruct(SC(h).(F{i}))
                NameLevelStuct = unfold(SC(h).(F{i}),Namei,show,NameLevelStuct);
            else
                if iscell(SC(h).(F{i}))
                    siz = size(SC(h).(F{i}));
                    NC = numel(SC(h).(F{i}));
%                     jmax = 1;
                    jmax = NC;
                    for j=1:jmax
                        cellStruct = SC(h).(F{i}){j};
                        Fn = fieldnames(cellStruct);
                        cellFieldsSize = length(Fn);

                        Namej = [Namei '{' num2str(j) '}'];

                         if ~isempty(strfind(Namej,'Attributes'))
                            NameLevelStuct = [NameLevelStuct; {Namej num2str(length(strfind(Namej,'.'))-3)}];
                        elseif ~isempty(strfind(Namej,'Comment')) || ~isempty(strfind(Namej,'Text'))
                            NameLevelStuct = [NameLevelStuct; {Namej num2str(length(strfind(Namej,'.'))-2)}];
                        else
                            NameLevelStuct = [NameLevelStuct; {Namej num2str(length(strfind(Namej,'.'))-1)}];
                        end

                        for ji = 1:cellFieldsSize
                            Nameji = [Namej '.' Fn{ji}];

                            if isstruct(SC(h).(F{i}){j}.(Fn{ji}))
                                NameLevelStuct = unfold(SC(h).(F{i}){j}.(Fn{ji}),Nameji,show,NameLevelStuct);
                            else
                                if ~isempty(strfind(Nameji,'Attributes'))
                                    NameLevelStuct = [NameLevelStuct; {Nameji num2str(length(strfind(Nameji,'.'))-3)}];
                                elseif ~isempty(strfind(Nameji,'Comment')) || ~isempty(strfind(Nameji,'Text'))
                                    NameLevelStuct = [NameLevelStuct; {Nameji num2str(length(strfind(Nameji,'.'))-2)}];
                                else
                                    NameLevelStuct = [NameLevelStuct; {Nameji num2str(length(strfind(Nameji,'.'))-1)}];
                                end
                            end
                        end
                    end
                else
%                     disp(Namei)
%                     disp(length(strfind(Namei,'.')))
                    if ~isempty(strfind(Namei,'Attributes'))
                            NameLevelStuct = [NameLevelStuct; {Namei num2str(length(strfind(Namei,'.'))-3)}];
                        elseif ~isempty(strfind(Namei,'Comment')) || ~isempty(strfind(Namei,'Text'))
                            NameLevelStuct = [NameLevelStuct; {Namei num2str(length(strfind(Namei,'.'))-2)}];
                        else
                            NameLevelStuct = [NameLevelStuct; {Namei num2str(length(strfind(Namei,'.'))-1)}];
                        end
                end
            end
        end
    end
elseif iscell(SC)
    %recursively display cell
    siz = size(SC);
    for i=1:numel(SC)
        Namei = [Name '{' ind2str(siz,i) '}'];
        NameLevelStuct = unfold(SC{i},Namei,show,NameLevelStuct);
    end
else
%     disp(Name)
    NameLevelStuct = [NameLevelStuct; {Name num2str(length(strfind(Name,'.'))-1)}];
end

%local functions
%--------------------------------------------------------------------------
function str = ind2str(siz,ndx)

n = length(siz);
%treat vectors and scalars correctly
if n==2
    if siz(1)==1
        siz = siz(2);
        n = 1;
    elseif siz(2)==1
        siz = siz(1);
        n = 1;
    end
end
k = [1 cumprod(siz(1:end-1))];
ndx = ndx - 1;
str = '';
for i = n:-1:1
    v = floor(ndx/k(i))+1;
    if i==n
        str = num2str(v);
    else
        str = [num2str(v) ',' str];
    end
    ndx = rem(ndx,k(i));
end

