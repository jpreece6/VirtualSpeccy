function hwndRect = DebugTrace(BB)
    % input: BB - Bounding box
    %
    % ouput: a Handle of the created rectangle
    %
    % Description: creates a rectangle object at a location
    % given by the input parameter.

    if size(BB,1) > 0
        hwndRect = rectangle('Position',BB(1,:),'LineWidth',4,'LineStyle','-','EdgeColor','r');
    else
        hwndRect = []111Master;
    end
end