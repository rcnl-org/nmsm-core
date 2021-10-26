% 
% read = parseXML("tests\core\JointModelPersonalizationSettings.xml");
% 
% read

% fieldnames(read.OpenSimDocument)

% fieldnames(read.OpenSimDocument.JointModelPersonalizationTool)

% tree = xmlread(strcat(pwd, "\tests\core\SimpleXML.xml"));

% tree.getChildNodes.item(0).getChildNodes.item(0)
formatSpec = '%s';
fid = fopen("tests\core\SimpleXML.xml", 'r');
text = '';
newtext = fgetl(fid);
newtext = replace(newtext,char(9),'');
while newtext ~= -1
    text = strcat(text, newtext);
    newtext = fgetl(fid);
    if(ischar(newtext))
        newtext = replace(newtext,char(9),'');
    end
end


% newtext = replace(newtext,char(10),'');
% newtext = replace(newtext,'\b%c','');
fid = fopen("tests\core\tempXML.xml",'wt');
fprintf(fid, text);
fclose(fid);
% 
% simpleXML = parseXML("tests\core\tempXML.xml");
% 
% fid = fopen("tests\core\tempXML.xml");
% text = ''
% while

% tree = addChildren(simpleXML)

function tree = addChildren(root)
    tree=struct();
    if(isempty(root.Children))
        tree.Name = root.Name;
        tree.Data = root.Data;
        tree.Attributes = root.Attributes;
    else
       for i=1:length(root.Children)
           try
            children = addChildren(root.Children(i))

            tree.(root.Children(i).Name) = children;
           catch
           end
       end
    end
end


function output = structContains(obj, field)
    fields = fieldnames(obj);
    output = false;
    for i=1:length(fields)
        if(fields(i)==field)
            output = true;
            break
        end
    end
end
