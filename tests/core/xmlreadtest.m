% 
% read = parseXML("tests\core\JointModelPersonalizationSettings.xml");
% 
% read

% fieldnames(read.OpenSimDocument)

% fieldnames(read.OpenSimDocument.JointModelPersonalizationTool)

simpleXML = parseXML("tests\core\SimpleXML.xml");

tree = addChildren(simpleXML)

function tree = addChildren(root)
    tree=struct();
    if(isempty(root.Children))
        tree.Name = root.Name
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

