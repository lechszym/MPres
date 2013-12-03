function demo1()
% Run this demo to see what MPres can do.
% Read this file to see how to write a script for your presentation.

%Initialise mpres presentation structure
%with default settings
pres = mpres;

%Overwriting some defaults

%Title of the matlab figure, where presentation will be run
pres.title = 'MPres demo';

%Run the presentation in full screen mode
pres.position = 'fullscreen';

%Frames per second - this is best effort based, since Matlab is rather
%slow, and so the frame rate is not guaranteed.
pres.fs = 15;

%Set up slide sequence

%The slides are stored in the slide field of the
%pres structure.  For each slide we can specify a title string, which
%will remain on the through all the phases of that slide.  Each phase is
%a pointer to a function that programs the presentation - plots, text,
%animations, etc.

%First slide - only one phase
pres.slide{1}.phase{1}.f = @demotitle;

%Second slide - only one phase
pres.slide{2}.title = 'Presentation structure';
pres.slide{2}.phase{1}.f = @structure1;

%Third slide - two phases
pres.slide{3}.title = 'Navigation';
pres.slide{3}.phase{1}.f = @navigation1;
pres.slide{3}.phase{2}.f = @navigation2;

%Fourth slide - six phases
pres.slide{4}.title = 'Animation Basics';
pres.slide{4}.phase{1}.f = @animation;
pres.slide{4}.phase{2}.f = @animation_view;
pres.slide{4}.phase{3}.f = @animation_cont;
pres.slide{4}.phase{4}.f = @animation_resume1;
pres.slide{4}.phase{5}.f = @animation_resume2;
pres.slide{4}.phase{6}.f = @animation_data;

%Last slide - only one phase
pres.slide{5}.title = 'There''s more';
pres.slide{5}.phase{1}.f = @theres_more;


%Run the presentation
mpres(pres);


end


% *************************************************************************
%
%  Slide phases
%
% *************************************************************************

%This is the function for the only phase of the first slide.  The format
%of a phase function is data = functionname(data).  
%The data field allows passing of information from phase to phas (so that
%plots can be modified without deleting, animations resumed, etc).
function data = demotitle(data)

    %This phase just displays text
    h = subplot(1,1,1);
    set(h,'Position',[0.5 0.5 0.4 0.4]);

    %I find Latex rendering to give nice looking text
    text(-0.4,0.2,'$\mbox{MPres demo}$', 'Interpreter','Latex','FontSize',getFontSize*2);
    text(-0.81,-0.65,'$\begin{array}{l}\mbox{Press right arrow} \\ \mbox{to continue...}\end{array}$', 'Interpreter','Latex','FontSize',getFontSize);
    axis off;
    
end

%This is the function for the only phase of the second slide.
function data = structure1(data)

    %This phase just displays text
    subplot(1,2,1);
    axis off;
    text(-0.1,0.8,'$\bullet \mbox{ Presentation consists of a number of slides}$', 'Interpreter','Latex','FontSize',getFontSize);
    text(-0.1,0.7,'$\bullet \mbox{ Each slide clears all the data from the previous slide}$', 'Interpreter','Latex','FontSize',getFontSize);
    text(-0.1,0.6,'$\bullet \mbox{ A slide may consist of a number of phases}$', 'Interpreter','Latex','FontSize',getFontSize);
    text(-0.1,0.5,'$\bullet \mbox{ Data/figures are preserved from phase to phase}$', 'Interpreter','Latex','FontSize',getFontSize);
    text(-0.1,0.4,'$\bullet \mbox{ A slide then is a sequence of animations}$', 'Interpreter','Latex','FontSize',getFontSize);
    text(-0.1,0.3,'$\bullet \mbox{ Each phase is one sequence in an animation}$', 'Interpreter','Latex','FontSize',getFontSize);

    text(-0.1,0,'$\begin{array}{l}\mbox{Press right arrow} \\ \mbox{to continue...}\end{array}$', 'Interpreter','Latex','FontSize',getFontSize);

end

%This is the function for the first phase of the third slide.
function data = navigation1(data)

    %This phase just displays text
    subplot(1,2,1);
    axis off;
    text(-0.1,0.8,'$\bullet \mbox{ Right arrow - go to the next phase}$', 'Interpreter','Latex','FontSize',getFontSize);
end

%This is the function for the second phase of the third slide.
function data = navigation2(data)
    %More text
    text(-0.1,0.7,'$\bullet \mbox{ Up arrow   - skip to the next slide}$', 'Interpreter','Latex','FontSize',getFontSize);
    text(-0.1,0.6,'$\bullet \mbox{ Left arrow - return to the previous slide (to phase 1)}$', 'Interpreter','Latex','FontSize',getFontSize);
    text(-0.1,0.5,'$\bullet \mbox{ Down arrow - stop an animation}$', 'Interpreter','Latex','FontSize',getFontSize);
    text(-0.1,0.4,'$\bullet \mbox{ Esc        - exit the presentation}$', 'Interpreter','Latex','FontSize',getFontSize);

end

%This is the function for the first phase of the fourth slide.
function data = animation(data)
    %Load sample data
    load fisheriris.mat;
    
    %Save the handle for text subplot in data structure (will be referring
    %to it later)
    data.ht = subplot(2,1,1);
    text(0,0.7,'$\bullet \mbox{ Here''s a 3D plot}$', 'Interpreter','Latex','FontSize',getFontSize);
    axis off;
    
    %Save the handle for data subplot in data structure (will be referring
    %to it later)
    data.h = subplot(2,1,2);
    %Save plotted data in data structure (will be replotting it later)
    data.x = meas(:,1:3)'; %#ok<NODEF>
    %Plot iris data
    data.hplot(1) = plot3(data.x(1,:),data.x(2,:),data.x(3,:),'.b');
    view([15 0]);
    axis([4 8 2 6 1 7]);
    axis off;
end

%This is the function for the second phase of the fourth slide.
function data = animation_view(data)
    %Switch to the text subplot
    subplot(data.ht)
    %Display more text
    text(0,0.55,'$\bullet \mbox{ You can animate plot''s view }$', 'Interpreter','Latex','FontSize',getFontSize);
    
    %Animate the view of the data subplot.  The animation will run just
    %once and stop.
    mpresAnimate(6,'view',data.h,[75 0]);
end

%This is the function for the third phase of the fourth slide.
function data = animation_cont(data)
    %Switch to the text subplot
    subplot(data.ht)
    %Display more text
    text(0,0.4,'$\bullet \mbox{ You can create a continuous animation }$', 'Interpreter','Latex','FontSize',getFontSize);
    %Animate the view of the data subplot (from where it finished in the
    %previous animation back to the starting values for the view).  This
    %animation will continue back and forth until user goes to the next
    %phase.
    data.animation = mpresAnimate(6,'view',data.h,[15 0],'cont');
end

%This is the function for the fourth phase of the fourth slide.
function data = animation_resume1(data)
    %Switch to the text subplot
    subplot(data.ht)
    %Display more text
    text(0,0.25,'$\bullet \mbox{ You can modify a plot while its view is animated }$', 'Interpreter','Latex','FontSize',getFontSize);

    %Switch to the data subplot
    subplot(data.h);
    hold on;
    hplot = data.hplot;  %You don't want to delete a plot until new one
                         %is drawn
    %Replot the data with different colours
    data.hplot(1) = plot3(data.x(1,1:50),data.x(2,1:50),data.x(3,1:50),'.r');
    data.hplot(2) = plot3(data.x(1,51:end),data.x(2,51:end),data.x(3,51:end),'.b');
    %Resume animation - the colours in the plot will change, but animation
    %will continue
    %Delete the data in the plot
    delete(hplot);
    data.animation = mpresAnimate(6,'resume',data.animation);
end

%This is the function for the fifth phase of the fourth slide.
function data = animation_resume2(data)
    %This phase does the same thing as the previous phase, except
    %it add more colours to the plots
    subplot(data.h);
    hplot = data.hplot;  %You don't want to delete a plot until new one
                         %is drawn
    data.hplot(1) = plot3(data.x(1,1:50),data.x(2,1:50),data.x(3,1:50),'.r');
    data.hplot(2) = plot3(data.x(1,51:100),data.x(2,51:100),data.x(3,51:100),'.m');
    data.hplot(3) = plot3(data.x(1,101:end),data.x(2,101:end),data.x(3,101:end),'.b');
    delete(hplot);
    data.animation = mpresAnimate(6,'resume',data.animation);
end

%This is the function for the sixth phase of the fourth slide.
function data = animation_data(data)
    %Switch to the text subplot
    subplot(data.ht)
    %Display more text
    text(0,0.1,'$\bullet \mbox{ You can animate plot data }$', 'Interpreter','Latex','FontSize',getFontSize);

    %Switch to the data subplot
    subplot(data.h);
    %Compute new values for the first 50 points of the data (corresponding
    %to points in handle data.hplot(1)
    y_red = [1 0.1 -0.2;0.5 2 -1; 0.4 0.4 -0.1]*data.x(:,1:50);
    
    %Compute new values for the second 50 ponts of the data (corresponding
    %to points in handle data.hplot(2)    
    delta = -pi/20;
    y_mag = [cos(delta)  0 sin(delta); ...
                 0       1    0      ;...
             -sin(delta) 0 cos(delta)]*data.x(:,51:100);
    
    %Animate the change of data values in the plot
    data.animation = mpresAnimate(6,'cont','data',data.hplot(1:2),{y_red y_mag});
end

%This is the function for the first phase of the fifth slide.
function data = theres_more(data)
    %Display some text
    subplot(1,2,1);
    axis off;
    text(0,0.8,'$\bullet \mbox{ Displaying a background image}$', 'Interpreter','Latex','FontSize',getFontSize);
    text(0,0.7,'$\bullet \mbox{ Animation of axis and position}$', 'Interpreter','Latex','FontSize',getFontSize);
    text(0,0.6,'$\bullet \mbox{ Animation of multiple attributes of a plot}$', 'Interpreter','Latex','FontSize',getFontSize);
    text(0,0.5,'$\mbox{   at the same time}$', 'Interpreter','Latex','FontSize',getFontSize);
    text(0,0.4,'$\bullet \mbox{ Jumping to slides}$', 'Interpreter','Latex','FontSize',getFontSize);
    text(0,0.3,'$\bullet \mbox{ Dumping screen to pdf}$', 'Interpreter','Latex','FontSize',getFontSize);

    text(0,0.1,'$\mbox{Look through the mpres.m and mpresAnimate.m}$', 'Interpreter','Latex','FontSize',getFontSize);
    text(0,0,'$\mbox{as well as demo1.m (the code for this demo)}$', 'Interpreter','Latex','FontSize',getFontSize);
end



% *************************************************************************
%
%  Helper functions
%
% *************************************************************************

%This function sets a fontsize that is relative to presentation
%size (will have to incorporate it into the toolbox at some point)
function s = getFontSize
    div = 35;
    pos = get(gcf, 'Position');
    height = pos(3);
    s = ceil(height/div);
end

