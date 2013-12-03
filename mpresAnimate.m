function state = mpresAnimate(duration,varargin)
% MPres animate
%
% Triggers an animation from a phase function
%
% state = mpresAnimate(duration,...)
%
% Input:
%    duration - number of seconds the animation is supposed to last for
%               (timing not guaranteed, but dictates the number of frames
%                the animation will attempt to render)
%    
%    The reminder of the input is a combination of any of the following
%    inputs:
%
%    'view',hView,targetView
%         Animates the view associated with subplot handle(s) hView
%         from current view to the values specified in targetView.  If 
%         hView is a 1xM vector of handles, targetView is an Mx2 matrix.
%
%    'axis',hAxis,targetAxis
%         Animates the axis associated with subplot handle(s) hAxis from
%         current axis values to the values specified in targetAxis.  If
%         hAxis is a 1xM vector of handles, targetAxis is an Mx4 matrix.
%
%    'data',hData,targetData
%         Animates the data associated with plot handle(s) hPlot from
%         current values to the values specified in targetData.  If
%         hData is a 1xM vector of handles, targetData is a 1xM cell where
%         for m'th cell targetData{m} is a DxN matrix of point coordinates
%         for N points that are plotted in D-dimensional plot with handle
%         hPlot(m).
%
%    'cont'
%         Makes the animation continuous (back and forth between current
%         state and the target state).
%
%    'resume',state
%         Resumes animation from a previous state (which is returned from
%         this function and contains all the information necesssary to 
%         continue the animation).  Duration parameter is ignored when
%         resuming animation and the duration from the state is used.
%       
%
% Output:
%
%    state - the state animation finished at (useful for resuming the
%            animation in later frame)

    global mpresStopAnimation;
    global mpresState;
    global mpresEvent;
    global mpresStopButton;
    
    tStart = tic;
 
    mpresState = 'animation';
    mpresStopAnimation = 0;
    
    nVarargs = length(varargin);
    k = 1;
    fs = 20;
    
    flagView = 0;
    flagAxis = 0;
    flagData = 0;
    flagPos = 0;
    flagColorMap = 0;
    flagContinuous = 0;
    flagResume = 0;
    flagAxisEqual = 0;
    stopFrame = 0;
    
    while(k<=nVarargs)
        opt = varargin{k};
        switch opt
            
            case 'view'
                flagView = 1;
                k = k+1;
                hView = varargin{k};
                k = k+1;
                newView = varargin{k};
            

            case 'axis'
                flagAxis = 1;
                k = k+1;
                hAxis = varargin{k};
                k = k+1;
                newAxis = varargin{k};
            
            case 'data'
                flagData = 1;
                k = k+1;
                hData = varargin{k};
                k = k+1;
                newData = varargin{k};
                
            case 'pos'
                flagPos = 1;
                k = k+1;
                hPos = varargin{k};
                k = k+1;
                newPos = varargin{k};
                
            case 'colormap'
                flagColorMap = 1;
                k = k+1;
                hColorMap = varargin{k};
                k = k+1;
                newColorMap = varargin{k};
                
            case 'fs'
                k = k+1;
                fs = varargin{k};
                if(fs > 30)
                    fs = 30;
                end
                
            case 'resume'
                k = k+1;
                resumeState = varargin{k};
                flagResume = 1;
                
            case 'cont'
                flagContinuous = 1;

            case 'untilFrame'
                k = k+1;
                stopFrame = varargin{k};
                
                
            case 'equal'
                flagAxisEqual = 1;
                
            otherwise
                error('Unrecognised option "%s"',opt);
        end
        k = k+1;
    end
    
    flagResumeView = false;
    flagResumeData = false;

    if(flagResume)
        if(resumeState.flagView)
            flagView = resumeState.flagView;
            flagResumeView = true;
        end
        if(resumeState.flagData)
            flagData = resumeState.flagData;
            flagResumeData = true;
        end
        if(resumeState.flagContinuous)
            flagContinuous = resumeState.flagContinuous;
        end
        duration = resumeState.duration;        
    end
        
    nFrames = round(duration*fs);
    pauseTime = 1/fs;

    state.flagView = flagView;
    state.flagData = flagData;
    state.flagContinuous = flagContinuous;
    state.duration = duration;
    
    if(flagContinuous && ~stopFrame)
        if(mpresStopButton)
            load('mpresicons.mat','stop_icon');
            cmd_stop = uicontrol('Style','pushbutton','CData',stop_icon,'Position',[60 10 30 30], 'Callback', 'global mpresStopAnimation;mpresStopAnimation =1;');
        end
    end
    
    if(flagView)
        
        if(~flagResumeView)
            nPlots = length(hView);
            oldView = zeros(nPlots,2);
            framedEl = zeros(nPlots,nFrames);
            framedAz = zeros(nPlots,nFrames);

            for nr=1:nPlots
                 oldView(nr,:) = get(hView(nr),'View');
                 framedAz = linspace(oldView(nr,1),newView(1),nFrames);
                 framedEl = linspace(oldView(nr,2),newView(2),nFrames);                 
            end
        else
            hView = resumeState.hView;
            framedAz = resumeState.framedAz;
            framedEl = resumeState.framedEl;
        end
    end
    
    if(flagAxis)
        nPlots = length(hAxis);

        framedAxis = cell(1,nPlots);
        for nr=1:nPlots
           oldAxis = axis(hAxis(nr));
           framedAxis{nr} = zeros(nFrames,length(oldAxis));
           for nz=1:length(oldAxis)
               framedAxis{nr}(:,nz) = linspace(oldAxis(nz),newAxis(nz),nFrames);
           end
        end
    end
    
    if(flagData)
       if(~flagResumeData)
           nPlots = length(hData);
           framedData = cell(1,nPlots);
           for nr=1:nPlots
               [M,N] = size(newData{nr});
               oldData = zeros(M,N);
               oldData(1,:) = get(hData(nr),'XData');
               oldData(2,:) = get(hData(nr),'YData');
               if(M>2)
                   oldData(3,:) = get(hData(nr),'ZData');
               end
               framedData{nr} = zeros(M,N,nFrames);
               for i=1:M
                  I = isnan(oldData(i,:));
                  if(any(I))
                     framedData{nr}(i,I,:) = repmat(oldData(i,I)',1,nFrames);
                  end
                  I = ~I;
                  if(any(I))
                      framedData{nr}(i,I,:) = mpresLinspace(oldData(i,I),newData{nr}(i,I),nFrames);
                  end
               end
           end       
       else
           hData = resumeState.hData;
           framedData = resumeState.framedData;
       end
    end
    
    if(flagPos)
        nPlots = length(hPos);
        framedPos = cell(nPlots);
    
        for nr=1:nPlots
            oldPos = get(hPos(nr),'Position');
            framedPos{nr} = zeros(nFrames,4);            
            for j=1:4
                framedPos{nr}(:,j) = linspace(oldPos(j),newPos(nr,j),nFrames);
            end
        end
    end
    
    if(flagColorMap)
        nPlots = length(hColorMap);

        framedColorMap = cell(1,nPlots);
        for nr=1:nPlots
            oldColorMap = colormap(hColorMap{nr});
            for j=1:3
                framedColorMap{nr}(j,:) = linspace(oldColorMap(j),newColorMap(j),nFrames);
            end
        end
    end

    while(1)
        
        if(flagResume)
            startFrame = resumeState.lastFrame+1;
        else
            startFrame = 1;
        end    
        
        
        for i=startFrame:nFrames

            if(flagView)
                nPlots = length(hView);
                for nr=1:nPlots
                    set(hView(nr),'View',[framedAz(nr,i) framedEl(nr,i)]);
                end
            end
    
            if(flagAxis)
                nPlots = length(hAxis);
                for nr=1:nPlots
                    set(hAxis(nr),'XLim',framedAxis{nr}(i,1:2));
                    set(hAxis(nr),'YLim',framedAxis{nr}(i,3:4));
                    if(size(framedAxis{nr},2) > 4)
                        set(hAxis(nr),'ZLim',framedAxis{nr}(i,5:6));
                    end                    
                end
            end
               
            if(flagData)
                nPlots = length(hData);
                for nr=1:nPlots
                   set(hData(nr),'XData',framedData{nr}(1,:,i));
                   set(hData(nr),'YData',framedData{nr}(2,:,i));
                   if(size(framedData{nr},1) > 2)
                       set(hData(nr),'ZData',framedData{nr}(3,:,i));
                   end                   
                end
            end
                
            if(flagPos)
                nPlots = length(hPos);
                for nr=1:nPlots                    
                    set(hPos(nr),'Position',framedPos{nr}(i,:));
                end
            end
                
            if(flagColorMap)
                nPlots = length(hColorMap);
                for nr=1:nPlots
                    colormap(h,framedColorMap{nr}(:,i)');
                end
            end

            if(flagAxisEqual)
                axis equal;
            end
            
            refresh;
            state.lastFrame = i;

            if(~strcmp(mpresEvent,'none'))
                mpresStopAnimation = 1;
            end
            
            if(stopFrame && (i==stopFrame))
                mpresStopAnimation = 1;
            end
            
            
            if(mpresStopAnimation)
                break;
            end
            
            
            tElapsed = toc(tStart);
            tStart = tic;
            
            if(tElapsed < pauseTime)
               pauseFor = pauseTime-tElapsed; 
               pause(pauseFor);
            end
            

            
        end
        
        if(mpresStopAnimation)
             break;
        end

        if(mpresStopAnimation || ~flagContinuous)
            break;
        end
        
        if(flagView)
            nPlots = length(hView);
            for nr=1:nPlots
               framedAz = fliplr(framedAz);
               framedEl = fliplr(framedEl);
            end
        end
        
        if(flagData)
           nPlots = length(hData);
           for nr=1:nPlots            
                framedData{nr} = framedData{nr}(:,:,end:-1:1);
           end
        end
        
        if(flagAxis)
            nPlots = length(hAxis);
            for nr=1:nPlots
                framedAxis{nr} = framedAxis{nr}(end:-1:1,:);
            end
        end
            
        
        if(flagColorMap)
            nPlots = length(hColorMap);
            for nr=1:nPlots
                framedColorMap{nr} = fliplr(framedColorMap{nr});
            end
        end
        flagResume = 0;
    end
    
    if(flagContinuous)
        if(~stopFrame)
            if(mpresStopButton)
                delete(cmd_stop);
            end
        end
    end        
        
    
    if(flagView)
        state.hView = hView;
        state.framedAz = framedAz;
        state.framedEl = framedEl;
    end
    
    if(flagData)
        state.hData = hData;
        state.framedData = framedData;
    end
end

function z = mpresLinspace(x,y,nFrames)
    z = interp1([1 nFrames],[x(:) y(:)]',1:nFrames)';
end

