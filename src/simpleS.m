function simpleS
% SIMPLE_GUI2 Select a data set from the pop-up menu, then
% click one of the plot-type push buttons. Clicking the button
% plots the selected data in the axes.
 
   %  Create and then hide the GUI as it is being constructed.
   f = figure('Visible','off','Position',[360,500,450,285]);
 
   %  Construct the components. Want 4 check boxes: S11, S21, S12, S22
 
   hGetFile = uicontrol('Style','pushbutton',...
          'String','Open File',...
          'Position',[300,135,70,25],...
          'Callback',{@getFile_Callback}); 
   hpopup = uicontrol('Style','popupmenu',...
          'String',{'Amplitude [dB]','Phase [deg]'},...
          'Position',[300,50,100,25],...
          'Callback',{@popup_menu_Callback});
      
   hS11sel = uicontrol('Style','checkbox',...
          'String','S11',...
          'Position',[315,220,50,10],...
          'Callback',{@S11_Callback});
      
   hS21sel = uicontrol('Style','checkbox',...
          'String','S21',...
          'Position',[315,200,50,10],...
          'Callback',{@S21_Callback});
      
   hS12sel = uicontrol('Style','checkbox',...
          'String','S12',...
          'Position',[315,180,50,10],...
          'Callback',{@S12_Callback});
   hS22sel = uicontrol('Style','checkbox',...
          'String','S22',...
          'Position',[315,160,50,10],...
          'Callback',{@S22_Callback});
      
   ha = axes('Units','Pixels','Position',[50,60,200,185]); 
   align([hS11sel,hS12sel,hS21sel,hS22sel,hGetFile,hpopup],'Center','None');

   
   % Initialize the GUI.
   % Change units to normalized so components resize 
   % automatically.
   set([f,ha,hS11sel,hS21sel,hS12sel,hS22sel,hGetFile,hpopup],...
   'Units','normalized');
   %Create a plot in the axes.
   current_data_x = zeros(10,1);
   current_data_y = [zeros(10,1) zeros(10,1)];
   current_data_S = [];
   SplotSel = [0,0;0,0];
   plot_type = 0;
   
   legend_string = {'0','0'};
   plot(current_data_x,current_data_y);
   legend(legend_string,'Location','NorthEast')
   % Assign the GUI a name to appear in the window title.
   set(f,'Name','S2P GUI')
   % Move the GUI to the center of the screen.
   movegui(f,'center')
   % Make the GUI visible.
   set(f,'Visible','on');
 
   %  Callbacks for simple_gui. These callbacks automatically
   %  have access to component handles and initialized data 
   %  because they are nested at a lower level.
 
   %  Pop-up menu callback. Read the pop-up menu Value property
   %  to determine which item is currently displayed and make it
   %  the current data.
   function popup_menu_Callback(source,eventdata) 
         % Determine the selected data set.
         str = get(source, 'String');
         val = get(source,'Value');
         % Set current data to the selected data set.
         switch str{val};
         case 'Amplitude [dB]' % User selects Peaks.
            plot_type = 0;
         case 'Phase [deg]' % User selects Membrane.
            plot_type = 1;
         end
         plotData;
      end
  
   % Push button callbacks. Each callback plots current_data in
   % the specified plot type.
 
    function plotData
        % SplotSel determines which are to plotted.
        current_data_y = [];
        current_legend = {};
        if SplotSel(1,1) == 1
            current_data_y = [current_data_y squeeze(current_data_S(1,1,:))];
            current_legend = cat(1,current_legend,'S11');
        end
        if SplotSel(2,1) == 1
            current_data_y = [current_data_y squeeze(current_data_S(2,1,:))];
            current_legend = cat(1,current_legend, 'S21');
        end
        if SplotSel(1,2) == 1
            current_data_y = [current_data_y squeeze(current_data_S(1,2,:))];
            current_legend = cat(1,current_legend, 'S12');
        end
        if SplotSel(2,2) == 1
            current_data_y = [current_data_y squeeze(current_data_S(2,2,:))];
            current_legend = cat(1,current_legend, 'S22');
        end
        
        if plot_type == 0
           % amplitude
           current_data_y = 20*log10(abs(current_data_y));
           ylab = 'Amplitude [dB]';
        elseif plot_type == 1
            current_data_y = 180/pi*angle(current_data_y);
            ylab = 'Phase [deg]';
        end
        if isempty(current_data_y)
            current_data_y = zeros(size(current_data_x));
        end
        plot(current_data_x,current_data_y)
        legend(current_legend,'Location','NorthEast')
        ylabel(ylab)
        xlabel('Frequency [GHz]')
        
    end

    function getFile_Callback(source,eventdata)
        [FileName,PathName] = uigetfile({'*.s2p','*.S2P'},'Select the S2P-file');
        [f,S] = importS2P([PathName FileName]);
        current_data_x = f;
        current_data_S = S;
        plotData;
    end

    function S11_Callback(source,eventdata)
        if (get(source,'Value') == get(source,'Max'))
            SplotSel(1,1) = 1;
        else
            SplotSel(1,1) = 0;
        end
        plotData;
    end

    function S12_Callback(source,eventdata)
        if (get(source,'Value') == get(source,'Max'))
            SplotSel(1,2) = 1;
        else
            SplotSel(1,2) = 0;
        end
        plotData;
    end

    function S21_Callback(source,eventdata)
        if (get(source,'Value') == get(source,'Max'))
            SplotSel(2,1) = 1;
        else
            SplotSel(2,1) = 0;
        end
        plotData;
    end

    function S22_Callback(source,eventdata)
        if (get(source,'Value') == get(source,'Max'))
            SplotSel(2,2) = 1;
        else
            SplotSel(2,2) = 0;
        end
        plotData;
    end
 
end 