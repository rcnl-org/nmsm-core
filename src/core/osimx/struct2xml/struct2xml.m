function varargout = struct2xml_modified( inputStructure2Xml, varargin )
%Convert a MATLAB structure into a xml file 
% [ ] = struct2xml( s, file )
% xml = struct2xml( s )
%
% A structure containing:
% x.XmlDocument.Attributes.Version = 'Version';
% x.XmlDocument.XmlName.Attributes.name = 'Attribute Name';
% x.XmlDocument.XmlName.PropertyOne.Comment = 'Some Comment';
% x.XmlDocument.XmlName.PropertyOne.Text = 'Some Text';
% x.XmlDocument.XmlName.Element{1}.Attributes.name = 'Attribute Name';
% x.XmlDocument.XmlName.Element{1}.element_name.Comment = 'Some Comment';
% x.XmlDocument.XmlName.Element{1}.element_name.Text = 'Some Text';
% x.XmlDocument.XmlName.Element{2}.Attributes.name = 'Attribute Name';
% x.XmlDocument.XmlName.Element{2}.element_name.Comment = 'Some Comment';
% x.XmlDocument.XmlName.Element{2}.element_name.Text = 'Some Text';
% 
% 
% Will produce:
% <?xml version="1.0" encoding="utf-8"?>
% <XmlDocument Version="Version">
%    <XmlName name="Attribute Name">
%       <!--Some Comment-->
%       <PropertyOne>Some Text</PropertyOne>
%       <Element name="Attribute Name">
%          <!--Some Comment-->
%          <element_name>Some Text</element_name>
%       </Element>
%       <Element name="Attribute Name">
%          <!--Some Comment-->
%          <element_name>Some Text</element_name>
%       </Element>
%    </XmlName>
% </XmlDocument>
%
% Please note that the following strings are substituted
% '_dash_' by '-', '_colon_' by ':' and '_dot_' by '.'
%
% Written by W. Falkena, ASTI, TUDelft, 27-08-2010
% On-screen output functionality added by P. Orth, 01-12-2010
% Multiple space to single space conversion adapted for speed by T. Lohuis, 11-04-2011
% Val2str subfunction bugfix by H. Gsenger, 19-9-2011
% Comment functionality added by M. Vega 5-3-2022
% Indentation fix by S. Williams 10-4-2025
    
if (nargin ~= 2)
    if(nargout ~= 1 || nargin ~= 1)
        error(['Supported function calls:' sprintf('\n')...
               '[ ] = struct2xml( s, file )' sprintf('\n')...
               'xml = struct2xml( s )']);
    end
end

if(nargin == 2)
    file = varargin{1};
    if (isempty(file))
        error('Filename can not be empty');
    end
    if (isempty(strfind(file, '.xml')))
        file = [file '.xml'];
    end
end

if (~isstruct(inputStructure2Xml))
    error([inputname(1) ' is not a structure']);
end
if (length(fieldnames(inputStructure2Xml)) > 1)
    error(['Error processing the structure:' sprintf('\n') 'There ' ...
        'should be a single field in the main structure.']);
end
xmlname = fieldnames(inputStructure2Xml);
xmlname = xmlname{1};

%substitute special characters
xmlname_sc = xmlname;
xmlname_sc = strrep(xmlname_sc, '_dash_', '-');
xmlname_sc = strrep(xmlname_sc, '_colon_', ':');
xmlname_sc = strrep(xmlname_sc, '_dot_', '.');

%create xml structure
docNode = com.mathworks.xml.XMLUtils.createDocument(xmlname_sc);

%process the rootnode
docRootNode = docNode.getDocumentElement;

%append childs
NameLevelStuct = unfold(inputStructure2Xml, false);
parseStruct(inputStructure2Xml.(xmlname), docNode, docRootNode, ...
    [inputname(1) '.' xmlname '.'], [], NameLevelStuct, 1, ...
    inputStructure2Xml);

if(nargout == 0)
    %save xml file
    xmlwrite(file, docNode);
else
    varargout{1} = xmlwrite(docNode);
end  
end

% ----- Subfunction parseStruct -----
function [indLevel] = parseStruct(inputStructure2Xml, docNode, curNode, ...
    pName, parent, NameLevelStuct, indLevel, xmlStruct)

fnames = fieldnames(inputStructure2Xml);
for i = 1:length(fnames)
    curfield = fnames{i};
    
    %substitute special characters
    curfield_sc = curfield;
    curfield_sc = strrep(curfield_sc, '_dash_', '-');
    curfield_sc = strrep(curfield_sc, '_colon_', ':');
    curfield_sc = strrep(curfield_sc, '_dot_', '.');
    
    if (strcmp(curfield,'Attributes'))
        %Attribute data
        if (isstruct(inputStructure2Xml.(curfield)))
            attr_names = fieldnames(inputStructure2Xml.Attributes);
            for a = 1:length(attr_names)
                cur_attr = attr_names{a};
                indLevel = indLevel + 1;
                %substitute special characters
                cur_attr_sc = cur_attr;
                cur_attr_sc = strrep(cur_attr_sc, '_dash_', '-');
                cur_attr_sc = strrep(cur_attr_sc, '_colon_', ':');
                cur_attr_sc = strrep(cur_attr_sc, '_dot_', '.');
                
                cur_str = strrep(inputStructure2Xml.Attributes.(cur_attr),"_dash_","-");
                cur_str = strrep(cur_str,"_colom_",":");
                cur_str = strrep(cur_str,"_dot_",".");

                [~, succes] = val2str(inputStructure2Xml.Attributes.(cur_attr));
                
                if (succes)
                    curNode.setAttribute(cur_attr_sc, cur_str);
                else
                    disp(['Warning. The text in ' pName curfield '.' ...
                        cur_attr ' could not be processed.']);
                end
            end
        else
            disp(['Warning. The attributes in ' pName curfield ...
                ' could not be processed.']);
            disp(['The correct syntax is: ' pName curfield ...
                '.attribute_name = ''Some text''.']);
        end
    elseif (strcmp(curfield,'Comment'))
        [txt,succes] = val2str(inputStructure2Xml.Comment);
        if (succes)
            indLevel = indLevel + 1;
            spacing = createSpacing(str2num(NameLevelStuct{indLevel,2}));
            parent.appendChild(docNode.createTextNode(sprintf(['\n' spacing])));
            parent.appendChild(docNode.createComment(txt));
            parent.appendChild(docNode.createTextNode(sprintf(['\n' spacing])));
        else
            disp(['Warning. The comment in ' pName curfield ' could not be processed.']);
        end

        if (isfield(inputStructure2Xml,'Text'))
            [txt,succes] = val2str(inputStructure2Xml.Text);
            if (succes) 
                indLevel = indLevel + 1;
                curNode.appendChild(docNode.createTextNode(txt));
            else
                disp(['Warning. The text in ' pName curfield ' could not be processed.']);
            end
            return;
        end
    else
        %Sub-element
        if (isstruct(inputStructure2Xml.(curfield)))
            %single element
            curElement = docNode.createElement(curfield_sc);
            indLevel = parseStruct(inputStructure2Xml.(curfield), ...
                docNode, curElement, [pName curfield '.'], curNode, ...
                NameLevelStuct, indLevel, xmlStruct);
            curNode.appendChild(curElement);
        elseif (iscell(inputStructure2Xml.(curfield)))
            %multiple elements
            for c = 1:length(inputStructure2Xml.(curfield))
                curElement = docNode.createElement(curfield_sc);
                curNode.appendChild(curElement);
                if (isstruct(inputStructure2Xml.(curfield){c}))
                    indLevel = indLevel + 1;
                    indLevel = parseStruct( ...
                        inputStructure2Xml.(curfield){c}, docNode, ...
                        curElement, [pName curfield '{' num2str(c) '}.'], ...
                        curNode, NameLevelStuct, indLevel, xmlStruct);
                else
                    disp(['Warning. The cell ' pName curfield '{' ...
                        num2str(c) '} could not be processed, since it ' ...
                        'contains no structure.']);
                end
            end
        else
            %eventhough the fieldname is not text, the field could
            %contain text. Create a new element and use this text
            curElement = docNode.createElement(curfield_sc);
            curNode.appendChild(curElement);
            [txt,succes] = val2str(inputStructure2Xml.(curfield));
            if (succes)
                % S. Williams: added next line to correctly advance through
                % indentation levels for text fields without comments 
                indLevel = indLevel + 1;
                curElement.appendChild(docNode.createTextNode(txt));
            else
                disp(['Warning. The text in ' pName curfield ' could ' ...
                    'not be processed.']);
            end
        end
    end
end
end

%----- Subfunction val2str -----
function [str,succes] = val2str(val)
    
    succes = true;
    str = [];
    
    if (isempty(val))
        return; %bugfix from H. Gsenger
    elseif (ischar(val))
        %do nothing
    elseif (isnumeric(val))
        val = num2str(val);
    else
        succes = false;
    end
    
    if (ischar(val))
        %add line breaks to all lines except the last (for multiline strings)
        lines = size(val,1);
        val = [val char(sprintf('\n') * [ones(lines - 1, 1);0])];
        
        %transpose is required since indexing (i.e., val(nonspace) or val(:)) produces a 1-D vector. 
        %This should be row based (line based) and not column based.
        valt = val';
        
        remove_multiple_white_spaces = true;
        if (remove_multiple_white_spaces)
            %remove multiple white spaces using isspace, suggestion of T. Lohuis
            whitespace = isspace(val);
            nonspace = (whitespace + [zeros(lines, 1) whitespace(:, 1:end- 1)]) ~= 2;
            nonspace(:, end) = [ones(lines - 1, 1);0]; %make sure line breaks stay intact
            str = valt(nonspace');
        else
            str = valt(:);
        end
    end
end

%----- Subfunction createSpacing -----
function spacing = createSpacing(level)

spacing = '';
for i = 1:level
    spacing = [spacing '   '];
end
end

%----- Subfunction substitureSpecialCharacters -----
function xmlname = substitureSpecialCharacters(xmlname)

xmlname = strrep(xmlname, '_dash_', '-');
xmlname = strrep(xmlname, '_colon_', ':');
xmlname = strrep(xmlname, '_dot_', '.');
end
