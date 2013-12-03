function pres = mpres(pres)
% MPres main function 
%
%   pres = mpres()
%   
%   When run without parameters returns the pres structure with default
%   settings
%
%   mpres(pres)
%
%   Runs the presentation loaded into the pres structure
%
%   
%   The pres structure:
%
%   pres.bkgcolour - colour of the background
%   pres.playButton - if set to 1 displays a play button that can be
%                     used for phase navigation
%   pres.stopButton - if set to 1 displays a stop button during continuous
%                     animations so that they can be stopped by pressing
%                     the button
%   pres.position - presentation position, use 'full' for full screen
%   pres.fontName - the font name used for titles
%   pres.fontSize - the font size used for titles
%   pres.renderer - the renderer used of animation (same as figure
%                   render - if left empty will use autorenderer




    global mpresState;
    global mpresEvent;
    global mpresStopButton;
    global mpresScreenDump;
    
    if(~exist('pres','var'))
        %Set presentation defaults
        
        %Set background colour to white
        pres.bkgcolour = [1 1 1];
        
        %Display play button for ability to advance slides by mouse click
        pres.playButton = 0;

        %For continous animation display stop button for ability to stop it
        pres.stopButton = 0;
        
        %Set to fullscreen mode
        %pres.position = 'fullscreen';
        pres.position = 'norm';
        
        pres.fontName = 'Arial';
        pres.fontSize = 'auto';
        
        pres.renderer = [];
        
        return;
    end

    %Main figure
    h=figure('KeyPressFcn',{@mpresCallback_KeyPress});
    mpresScreenDump = 1;
    set(h,'MenuBar','none','NumberTitle','off');

    if(isempty(pres.renderer))
        set(h,'RendererMode','auto');
    else
        set(h,'RendererMode','manual','Renderer',pres.renderer);
    end
        
    ht = [];
    
    if(isfield(pres,'position'))
        if(ischar(pres.position))
            if(strcmpi(pres.position,'fullscreen'))
                set(h,'units','normalized','outerposition',[0 0 1 1])
                set(h,'units','pixels');
            end
        else
            set(h,'Position',pres.position);            
        end
    end
   
    if(isfield(pres,'bkgcolour'))
       set(h,'Color',pres.bkgcolour);
    end

    if(isfield(pres,'title'))
        set(h,'Name',pres.title);
    end
    
    if(isfield(pres,'slidedata'))
        slidedata = pres.slidedata;
    else
        slidedata = [];
    end
    
    cmd_play = [];
    if(pres.playButton)
       load('mpresicons.mat','playb_icon');
    end

    if(ischar(pres.fontSize) && strcmp(pres.fontSize,'auto'))
        pres.fontSize = mpresGetFontSize();
    end
    
    nextSlide = 0;
    nextPhase = 0;
    mpresState = 'nextslide';
    mpresEvent = 'none';
    mpresStopButton = pres.stopButton;
    mpresStateMachine();
   
    function mpresStateMachine()

       
       while(1) 
       
           switch mpresState

               case 'finished'
                   close(gcf);
                   return;
                   
               case 'nextslide'
                   nextSlide = nextSlide + 1;
                   if(nextSlide > length(pres.slide))
                       nextSlide = length(pres.slide);
                       mpresState = 'idle';
                   else
                       clf(h);
                       ht = [];
                       if(pres.playButton)
                          cmd_play = uicontrol('Style','pushbutton','CData',playb_icon,'Position',[10 10 30 30], 'Callback', {@mpresCallback_NextButton});
                       end
               
                       if(isfield(pres,'bkgimg'))
                            mpresSlideBackground(pres.bkgimg,h); 
                       end           

                       slide = pres.slide{nextSlide};

                       if(isfield(slide,'bkgimg'))
                           mpresSlideBackground(slide.bkgimg,h); 
                       end

                       if(isfield(slide,'title'))
                           ht = mpresSlideTitle(slide.title,ht,pres.fontName, pres.fontSize);
                       end
                       
                       
                       nextPhase = 0;
                       mpresState = 'nextphase';
                   end
                   
                   
               case 'prevslide'
                   nextSlide = nextSlide - 2;
                   if(nextSlide < 0)
                       nextSlide = 0;
                   end
                   mpresState = 'nextslide';
                   
               case 'nextphase'
                   
                   nextPhase = nextPhase+1;
                   if(nextPhase > length(slide.phase))
                       mpresState = 'nextslide';
                   else
                      if(isfield(slide,'phase'))
                          phase = slide.phase{nextPhase};
    
                          if(isfield(phase,'title'))
                              ht = mpresSlideTitle(phase.title,ht,pres.fontName,pres.fontSize);
                          end
                          
                          if(isfield(phase,'f'))
                              slidedata = phase.f(slidedata);
                          end
                          mpresState = 'idle';
                      end
                   end
                   
               case 'idle'
                   if(strcmp(mpresEvent,'none'))
                       pause(0.5);
                   else
                       switch mpresEvent
                           case 'rightarrow'
                                mpresState = 'nextphase';
                           case 'uparrow'
                                mpresState = 'nextslide';
                           case 'leftarrow'
                                mpresState = 'prevslide';
                           case 'downarrow'
                               
                           case 'escape'
                                mpresState = 'finished';
                           case 's'
                                nextSlide = nextSlide-1;
                                mpresState = 'nextslide';
                           case 'p'
                               set(h,'PaperPositionMode','auto');         
                               %set(h,'PaperOrientation','landscape');
                               set(h,'PaperOrientation','landscape');
                               %set(h,'PaperUnits','normalized');
                               %set(h,'PaperPosition', [0 0 1.5 1.5]);
                               %set(h,'Position',[50 50 1200 800]);
                               
                               print(h, '-dpdf', sprintf('screendump%d.pdf',mpresScreenDump));
                               mpresScreenDump = mpresScreenDump+1;

                                
                                
                           otherwise
                               if(mpresEvent >= '1' && mpresEvent <= '9')
                                   nextSlide = double(mpresEvent)-49;
                                   mpresState = 'nextslide';
                               end
                       end        
                       mpresEvent = 'none';
                   end                   
               otherwise
                   error('Unknown satate ''%s''', mpresState);
                   
           end
       end
   end

   function  mpresCallback_KeyPress(source,evnt) %#ok<INUSL>
       
       if(strcmp(mpresState,'idle') || ...
          strcmp(mpresState,'animation'));
           mpresEvent = evnt.Key;
       end
   end

   function mpresCallback_NextButton(source,evnt)
       evnt.Key = 'rightarrow';
       mpresCallback_KeyPress(source,evnt)
   end    
end



%----------------------------------------------------------------------
% APPENDIX II: Support Functions (External)
%----------------------------------------------------------------------


function mpresSlideBackground(im,h)

figure(h);

[Him,Wim,~] = size(im);

posGca = get(gca,'Position');
Wperc = posGca(3);
Hperc = posGca(4);

set(gcf,'units','pixels');
posGcf = get(gcf,'Position');
Wsc = posGcf(3);
Hsc = posGcf(4);

Wdisp = floor(Wsc*Wperc);
Hdisp = floor(Hsc*Hperc);

rH = Him/Hdisp;
rW = Wim/Wdisp;

if(rH > 1)
   if(rW > 1)
      if(rH >= rW)
         Wdisp = floor(Wim/rH);
      else
         Hdisp = floor(Him/rW);
      end
   else
      Wdisp = floor(Wim/rH);
   end
else
   if(rW > 1)
      Hdisp = floor(Him/rW);
   else
      if(rH >= rW)
         Wdisp = floor(Wim/rH);         
      else
         Hdisp = floor(Him/rW);
      end
   end
end

im = imresize(im,[Hdisp Wdisp],'bicubic');
imshow(im);

end

function ht = mpresSlideTitle(titleStr,ht,fName,fSize)
    hSave = [];
    if(~isempty(ht))
        hSave = gca;
        delete(ht);
    end
    if(strcmp(fSize,'auto'))
        div = 35;
        pos = get(gcf, 'Position');
        height = pos(3);
        fSize = ceil(height/div);
    end
    
    axes('Position',[0.1 0.93 0.8 0.05]);
    ht = text(0,0,'');
    set(gca,'Visible','off');
    set(ht,'HorizontalAlignment','center');
    set(ht,'Position',[0.5 0.5]);
    set(ht,'FontName',fName,'FontSize',fSize,'FontWeight','bold');
    set(ht,'String',titleStr);
    if(~isempty(hSave))
        h=axes(hSave); %#ok<NASGU>
    end
end

function s = mpresGetFontSize()
    div = 35;
    pos = get(gcf, 'Position');
    height = pos(3);
    s = ceil(height/div);
end



