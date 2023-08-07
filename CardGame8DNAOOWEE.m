classdef CardGame8DNAOOWEE < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        DNAANDLabel              matlab.ui.control.Label
        RulesButton              matlab.ui.control.Button
        EndTurnButton            matlab.ui.control.Button
        DrawCard4Button          matlab.ui.control.Button
        DrawCard3Button          matlab.ui.control.Button
        DrawCard2Button          matlab.ui.control.Button
        Button_4                 matlab.ui.control.Button
        Button_3                 matlab.ui.control.Button
        Button_2                 matlab.ui.control.Button
        Button                   matlab.ui.control.Button
        Image2                   matlab.ui.control.Image
        Image4                   matlab.ui.control.Image
        Image3                   matlab.ui.control.Image
        Image1                   matlab.ui.control.Image
        ShuffleButton            matlab.ui.control.Button
        TextArea                 matlab.ui.control.TextArea
        TextAreaLabel            matlab.ui.control.Label
        StartButton              matlab.ui.control.Button
        Player1LPEditField       matlab.ui.control.NumericEditField
        Player1LPEditFieldLabel  matlab.ui.control.Label
        Player2LPEditField       matlab.ui.control.NumericEditField
        Player2LPEditFieldLabel  matlab.ui.control.Label
        DrawCard1Button          matlab.ui.control.Button
        WhosPlayingButtonGroup   matlab.ui.container.ButtonGroup
        Player2                  matlab.ui.control.RadioButton
        Player1                  matlab.ui.control.RadioButton
        Image                    matlab.ui.control.Image
    end

    
    properties (Access = private)
        PlayerNum % Who's turn it is
        OtherPlayerNum % Who's turn it is part 2
        ChannelID % ThingSpeak thing
        ReadKey % ThingSpeak thing
        WriteKey % ThingSpeak thing
        ReadDelay % Add if you are looping a ThingSpeak read func
        WriteDelay % Add if you are looping a ThingSpeak write func
        Deck % Self-explanatory
        MyHand % Description
        OtherHand % Description
        DamagePoints % Description
        StrikeUsed
    end
    
    methods (Access = private)
        
        
        function [] = ClearThingSpeak(app)
            %pause(app.WriteDelay);
            thingSpeakWrite(1246862, 'Fields',[1,2,3,4,5],'Values', {0,0,0,0,0}, 'WriteKey', 'Z1G4X4QXGSJJ9114');
            pause(app.WriteDelay);
            %thingSpeakWrite(app.ChannelID, 'Fields',2,'Values', 0, 'WriteKey', app.WriteKey);
            %pause(app.WriteDelay);
            %thingSpeakWrite(app.ChannelID, 'Fields',3,'Values', 0, 'WriteKey', app.WriteKey);
            %pause(app.WriteDelay);
            %thingSpeakWrite(app.ChannelID, 'Fields',4,'Values', 0, 'WriteKey', app.WriteKey);
            %pause(app.WriteDelay);
            %thingSpeakWrite(app.ChannelID, 'Fields',5,'Values', 0, 'WriteKey', app.WriteKey);
        end
        
        function [] = refreshDeck(app)
            % func to remake the deck -- could also be used as the shuffle
            deck = [1,1,1,1,1,1,1,1,2,2,2,2,3,3,3,3,3,3,3,3,4,4,4,4];
            count = length(deck);
            for count = 24
                deck = deck(randperm(numel(deck)));
            end
            pause(app.WriteDelay);
            thingSpeakWrite(app.ChannelID, 'Fields', 3, 'Values', {deck}, 'WriteKey', app.WriteKey);
        end
        
        function [] = IsItMyTurnYet(app)
            pause(app.ReadDelay);
            TurnOrder = thingSpeakRead(app.ChannelID, 'Fields', 5, 'ReadKey', app.ReadKey);
            
            while TurnOrder ~= app.PlayerNum
                set(app.TextArea,'Visible','on'); % keeps the waiting message on screen
                pause(app.ReadDelay); %keeps checking every 5 seconds if its your turn
                TurnOrder = thingSpeakRead(app.ChannelID, 'Fields', 5, 'ReadKey', app.ReadKey);
                
            end
            set(app.TextArea,'Visible','off'); % removes waiting message
            app.StartTurn();
        end

        
        function [] = PreventTheClicks(app) 
            set(app.DrawCard1Button,'Enable','off');
            set(app.DrawCard2Button,'Enable','off');
            set(app.DrawCard3Button,'Enable','off');
            set(app.DrawCard4Button,'Enable','off');
            set(app.Image1,'Enable','off');
            set(app.Image2,'Enable','off');
            set(app.Image3,'Enable','off');
            set(app.Image4,'Enable','off');
            set(app.ShuffleButton,'Enable','off');
            set(app.Button,'Enable','off');
            set(app.Button_2,'Enable','off');
            set(app.Button_3,'Enable','off');
            set(app.Button_4,'Enable','off');
            set(app.EndTurnButton,'Enable','off');
        end
        
        function [] = ResumeTheClicks(app)
            set(app.DrawCard1Button,'Enable','on');
            set(app.DrawCard2Button,'Enable','on');
            set(app.DrawCard3Button,'Enable','on');
            set(app.DrawCard4Button,'Enable','on');
            set(app.Image1,'Enable','on');
            set(app.Image2,'Enable','on');
            set(app.Image3,'Enable','on');
            set(app.Image4,'Enable','on');
            set(app.ShuffleButton,'Enable','on');
            set(app.Button,'Enable','on');
            set(app.Button_2,'Enable','on');
            set(app.Button_3,'Enable','on');
            set(app.Button_4,'Enable','on');
            set(app.EndTurnButton, 'Enable','on');
        end
        
        function results = DoesItHit(app)
            if app.PlayerNum == 1
                pause(app.ReadDelay)
                otherHandArray = thingSpeakRead(app.ChannelID, 'Fields', 2, 'ReadKey', app.ReadKey);
                results = any(otherHandArray == 2);
                otherHandArray(otherHandArray ==2) = 0;
                pause(app.WriteDelay)
                thingSpeakWrite(app.ChannelID,'Fields',2,'Values',otherHandArray,'WriteKey',app.WriteKey);
            else
                pause(app.ReadDelay)
                otherHandArray = thingSpeakRead(app.ChannelID, 'Fields', 1, 'ReadKey', app.ReadKey);
                results = any(otherHandArray == 2);
                otherHandArray(otherHandArray ==2) = 0;
                pause(app.WriteDelay)
                thingSpeakWrite(app.ChannelID,'Fields',1,'Values',otherHandArray,'WriteKey',app.WriteKey);
            end
        end
        
         function results = IsThisLoss(app)
            if app.PlayerNum == 1
                if app.Player1LPEditField.Value <= 0
                    msgbox("You have Lost")
                    results = 1;
                else
                    results = 0;
                end
            else
                if app.Player2LPEditField.Value <= 0
                    msgbox("You have Lost")
                    results = 1;
                else
                    results = 0;
                end
            end
        end
        
        function [] = StartTurn(app)
            tacoshop=randi(4,1,4);
             switch (tacoshop(1))
                 case 1
                     app.Image1.ImageSource = imread('Strike.png');
                 case 2
                     app.Image1.ImageSource = imread('Block.png');
                 case 3
                     app.Image1.ImageSource = imread('Potion.png');
                 case 4
                     app.Image1.ImageSource = imread('Boost.png');
             end
             switch (tacoshop(2))
                 case 1
                     app.Image2.ImageSource = imread('Strike.png');
                 case 2
                     app.Image2.ImageSource = imread('Block.png');
                 case 3
                     app.Image2.ImageSource = imread('Potion.png');
                 case 4
                     app.Image2.ImageSource = imread('Boost.png');
             end
             switch (tacoshop(3))
                 case 1
                     app.Image3.ImageSource = imread('Strike.png');
                 case 2
                     app.Image3.ImageSource = imread('Block.png');
                 case 3
                     app.Image3.ImageSource = imread('Potion.png');
                 case 4
                     app.Image3.ImageSource = imread('Boost.png');
             end
             switch (tacoshop(4))
                 case 1
                     app.Image4.ImageSource = imread('Strike.png');
                 case 2
                     app.Image4.ImageSource = imread('Block.png');
                 case 3
                     app.Image4.ImageSource = imread('Potion.png');
                 case 4
                     app.Image4.ImageSource = imread('Boost.png');
             end
            pause(app.ReadDelay)
            damage = thingSpeakRead(app.ChannelID, 'Fields', 4, 'NumPoints', 1, 'ReadKey', app.ReadKey);            
            if isnan(damage)
                damage = 0;
            end
            if app.PlayerNum == 1
                app.Player1LPEditField.Value = app.Player1LPEditField.Value-damage;
            else
                app.Player2LPEditField.Value = app.Player2LPEditField.Value-damage;
            end
            sadge = app.IsThisLoss();
            if sadge == 1
                app.PreventTheClicks();
                uiwait("Exiting Program",5)
                exit
               
            else
                app.DamagePoints = 0;
                app.StrikeUsed = 0;
                set(app.EndTurnButton,'Enable','on');
                set(app.EndTurnButton,'Visible','on');
                if app.PlayerNum == 1
                    pause(app.ReadDelay)
                    HandArray = thingSpeakRead(app.ChannelID, 'Fields', 1, 'ReadKey', app.ReadKey);
                    app.MyHand = [];
                    switch length(HandArray)
                        case 1
                            drawed(app, HandArray(1));
                        case 2
                            drawed(app, HandArray(1));
                            drawer2(app,HandArray(2));
                        case 3
                            drawed(app, HandArray(1));
                            drawer2(app,HandArray(2));
                            drawer3(app,HandArray(3));
                        case 4
                            drawed(app, HandArray(1));
                            drawer2(app,HandArray(2));
                            drawer3(app,HandArray(3));
                            drawer4(app,HandArray(4));
                    end
                    app.ResumeTheClicks();
                else
                    pause(app.ReadDelay)
                    HandArray = thingSpeakRead(app.ChannelID, 'Fields', 2, 'ReadKey', app.ReadKey);
                    app.OtherHand = [];
                    switch length(HandArray)
                        case 1
                            drawed(app, HandArray(1));
                        case 2
                            drawed(app, HandArray(1));
                            drawer2(app,HandArray(2));
                        case 3
                            drawed(app, HandArray(1));
                            drawer2(app,HandArray(2));
                            drawer3(app,HandArray(3));
                        case 4
                            drawed(app, HandArray(1));
                            drawer2(app,HandArray(2));
                            drawer3(app,HandArray(3));
                            drawer4(app,HandArray(4));
                    end
                    app.ResumeTheClicks();
                end
            end
            
        end
        
        function [] = EndTurn(app)
            app.PreventTheClicks();
            set(app.EndTurnButton,'Enable','off');
            set(app.EndTurnButton,'Visible','off');
            if app.PlayerNum ==1
                pause(app.WriteDelay)
                thingSpeakWrite(app.ChannelID,'Fields',4,'Values', app.DamagePoints, 'WriteKey', app.WriteKey);
                app.Player2LPEditField.Value = app.Player2LPEditField.Value - app.DamagePoints;
                if app.Player2LPEditField.Value <= 0
                    msgbox("You have won!")
                    app.PreventTheClicks();
                    uiwait("ExitingProgram",5)
                    exit
                end
                pause(app.WriteDelay)
                thingSpeakWrite(app.ChannelID,'Fields',5,'Values', 2, 'WriteKey', app.WriteKey);
                app.IsItMyTurnYet();
            else
                pause(app.WriteDelay)
                thingSpeakWrite(app.ChannelID,'Fields',4,'Values', app.DamagePoints, 'WriteKey', app.WriteKey);
                app.Player1LPEditField.Value = app.Player1LPEditField.Value - app.DamagePoints;
                if app.Player1LPEditField.Value <= 0
                    msgbox("You have won!")
                    app.PreventTheClicks();
                    uiwait("ExitingProgram",5)
                    exit
                end
                thingSpeakWrite(app.ChannelID,'Fields',5,'Values', 1, 'WriteKey', app.WriteKey);
                app.IsitMyTurnYet();
            end
        end
        
        
        function results = func10(app)
            
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.Deck = [];
            app.PlayerNum = 1;
            app.Player1LPEditField.Value = 3;
            app.Player2LPEditField.Value = 3;
            app.ChannelID = 1246862;
            app.WriteKey = 'Z1G4X4QXGSJJ9114';
            app.ReadKey = '02923j3T2X6LRHTH';
            app.ReadDelay = 5;
            app.WriteDelay = 5;
            app.PreventTheClicks();
            app.ClearThingSpeak();
            app.MyHand = [];
            app.OtherHand = [];
            app.DamagePoints = 0;
            app.StrikeUsed = 0;
            
           
            
        end

        % Selection changed function: WhosPlayingButtonGroup
        function WhosPlayingButtonGroupSelectionChanged(app, event)
            selectedButton = app.WhosPlayingButtonGroup.SelectedObject;
            if selectedButton == app.PlayerNum
                app.PlayerNum = 1;
                app.OtherPlayerNum = 2;
            else
                app.PlayerNum = 2;
                app.OtherPlayerNum = 1;
            end
        end

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            %takes away player selection and start button
            set(app.WhosPlayingButtonGroup,'Enable','off');
            set(app.WhosPlayingButtonGroup,'Visible','off');
            set(app.StartButton,'Enable','off');
            set(app.StartButton,'Visible','off');
            %lets the appropriate player start
            if (app.PlayerNum == 1)
                app.ResumeTheClicks();
                app.refreshDeck();
                app.StartTurn();
            else % you are player 2
                app.IsItMyTurnYet();
                
            end
%              tacoshop=randi(4,1,4);
%              switch (tacoshop(1))
%                  case 1
%                      app.Image1.ImageSource = imread('Strike.png');
%                  case 2
%                      app.Image1.ImageSource = imread('Block.png');
%                  case 3
%                      app.Image1.ImageSource = imread('Potion.png');
%                  case 4
%                      app.Image1.ImageSource = imread('Boost.png');
%              end
%              switch (tacoshop(2))
%                  case 1
%                      app.Image2.ImageSource = imread('Strike.png');
%                  case 2
%                      app.Image2.ImageSource = imread('Block.png');
%                  case 3
%                      app.Image2.ImageSource = imread('Potion.png');
%                  case 4
%                      app.Image2.ImageSource = imread('Boost.png');
%              end
%              switch (tacoshop(3))
%                  case 1
%                      app.Image3.ImageSource = imread('Strike.png');
%                  case 2
%                      app.Image3.ImageSource = imread('Block.png');
%                  case 3
%                      app.Image3.ImageSource = imread('Potion.png');
%                  case 4
%                      app.Image3.ImageSource = imread('Boost.png');
%              end
%              switch (tacoshop(4))
%                  case 1
%                      app.Image4.ImageSource = imread('Strike.png');
%                  case 2
%                      app.Image4.ImageSource = imread('Block.png');
%                  case 3
%                      app.Image4.ImageSource = imread('Potion.png');
%                  case 4
%                      app.Image4.ImageSource = imread('Boost.png');
%              end
        end

        % Button pushed function: ShuffleButton
        function ShuffleButtonPushed(app, event)
            deck = [1,1,1,1,1,1,1,1,2,2,2,2,3,3,3,3,3,3,3,3,4,4,4,4];
            count = length(deck);
            for count = 24
                deck = deck(randperm(numel(deck)));
            end
            [y,Fs]=audioread('shuffle_card.wav');
            sound(y,Fs);
            pause(app.WriteDelay);
            thingSpeakWrite(app.ChannelID, 'Fields', 3, 'Values', {deck}, 'WriteKey', app.WriteKey);
        end

        % Button pushed function: DrawCard1Button
        function drawed(app, event)
            sixnine=randi(24);
            deck = [1,1,1,1,1,1,1,1,2,2,2,2,3,3,3,3,3,3,3,3,4,4,4,4];
        if isequal(app.Image1.ImageSource,imread("DRAW.png"))
            [y,Fs]=audioread('draw.wav');
            sound(y,Fs);
            switch deck(sixnine)
                case 0 
                    app.Image1.ImageSource = imread('DRAW.png');
                case 1
                    app.Image1.ImageSource = imread('Strike.png');
                    if app.PlayerNum == 1
                        app.MyHand = [app.MyHand,1];
                    else
                        app.OtherHand = [app.OtherHand,1];
                    end
                case 2
                    app.Image1.ImageSource = imread('Block.png');
                    if app.PlayerNum == 1
                        app.MyHand = [app.MyHand,2];
                    else
                        app.OtherHand = [app.OtherHand,2];
                    end
                case 3
                    app.Image1.ImageSource = imread('Potion.png');
                    if app.PlayerNum == 1
                        app.MyHand = [app.MyHand,3];
                    else
                        app.OtherHand = [app.OtherHand,3];
                    end
                case 4
                    app.Image1.ImageSource = imread('Boost.png');
                    if app.PlayerNum == 1
                        app.MyHand = [app.MyHand,4];
                    else
                        app.OtherHand = [app.OtherHand,4];
                    end
            end
            pause(app.WriteDelay)
            if app.PlayerNum == 1
                disp(app.MyHand)
                thingSpeakWrite(app.ChannelID, 'Fields', 1, 'Values', reshape(app.MyHand,[1,1]), 'WriteKey', app.WriteKey);
            else
                thingSpeakWrite(app.ChannelID, 'Fields', 2, 'Values', reshape(app.OtherHand,[1,1]), 'WriteKey', app.WriteKey);
            end
        else
            msgbox("You already have a card for this Slot.")
        end
        end

        % Button pushed function: Button
        function card1(app, event)
            if isequal(app.Image1.ImageSource,imread("Strike.png"))
                if app.StrikeUsed == 1
                    msgbox("You can only use 1 Strike per turn")
                else
                    Blocked = app.DoesItHit();
                    if Blocked == 1
                        msgbox("Your Strike was blocked by the opponent!")
                        app.Image1.ImageSource = imread('DRAW.png');
                    else
                        msgbox("Your Strike went through, play a boost or end your turn to intialize Damage.")
                        app.Image1.ImageSource = imread('DRAW.png');
                        app.StrikeUsed = 1;
                        app.DamagePoints = 1;
                    end
                end
            elseif isequal(app.Image1.ImageSource,imread('Block.png'))
                msgbox("This card will be played automatically when able");
           
            elseif isequal(app.Image1.ImageSource,imread('Potion.png'))
                if app.PlayerNum == 1
                    if app.Player1LPEditField.Value < 3
                        app.Player1LPEditField.Value = app.Player1LPEditField.Value + 1;
                        app.Image1.ImageSource = imread('DRAW.png');
                    else
                        msgbox("You already have your maximum health points")
                    end
                else
                    if app.Player2LPEditField.Value < 3
                        app.Player2LPEditField.Value = app.Player2LPEditField.Value + 1;
                        app.Image1.ImageSource = imread('DRAW.png');
                    else
                        msgbox("You already have your maximum health points")
                    end
                    
                end
                
            elseif isequal(app.Image1.ImageSource,imread('Boost.png'))
                if app.StrikeUsed == 1
                    app.Image1.ImageSource = imread('DRAW.png');
                    app.DamagePoints = app.DamagePoints+1;
                    msgbox("Your damage has been increased")
                else
                    msgbox("This card can only be played if a Strike is played")
                end
                
            else
                msgbox("That is not an available card!")
                app.Image1.ImageSource = imread("DRAW.png");
            end
            
        end

        % Button pushed function: Button_2
        function card2(app, event)
            if isequal(app.Image2.ImageSource,imread("Strike.png"))
                if app.StrikeUsed == 1
                    msgbox("You can only use 1 Strike per turn")
                else
                    Blocked = app.DoesItHit();
                    if Blocked == 1
                        msgbox("Your Strike was blocked by the opponent!")
                        app.Image2.ImageSource = imread('DRAW.png');
                    else
                        msgbox("Your Strike went through, play a boost or end your turn to intialize Damage.")
                        app.Image2.ImageSource = imread('DRAW.png');
                        app.StrikeUsed = 1;
                        app.DamagePoints = 1;
                    end
                end
            elseif isequal(app.Image2.ImageSource,imread('Block.png'))
                msgbox("This card will be played automatically when able");
           
            elseif isequal(app.Image2.ImageSource,imread('Potion.png'))
                if app.PlayerNum == 1
                    if app.Player1LPEditField.Value < 3
                        app.Player1LPEditField.Value = app.Player1LPEditField.Value + 1;
                        app.Image2.ImageSource = imread('DRAW.png');
                    else
                        msgbox("You already have your maximum health points")
                    end
                else
                    if app.Player2LPEditField.Value < 3
                        app.Player2LPEditField.Value = app.Player2LPEditField.Value + 1;
                        app.Image2.ImageSource = imread('DRAW.png');
                    else
                        msgbox("You already have your maximum health points")
                    end
                    
                end
                
            elseif isequal(app.Image2.ImageSource,imread('Boost.png'))
                if app.StrikeUsed == 1
                    app.Image2.ImageSource = imread('DRAW.png');
                    app.DamagePoints = app.DamagePoints+1;
                    msgbox("Your damage has been increased")
                else
                    msgbox("This card can only be played if a Strike is played")
                end
                
            else
                msgbox("That is not an available card!")
                app.Image2.ImageSource= imread("DRAW.png");
            end
            
        end

        % Button pushed function: Button_3
        function card3(app, event)
            
            if isequal(app.Image3.ImageSource,imread('Strike.png'))
                if app.StrikeUsed == 1
                    msgbox("You can only use 1 Strike per turn")
                else
                    Blocked = app.DoesItHit();
                    if Blocked == 1
                        msgbox("Your Strike was blocked by the opponent!")
                        app.Image3.ImageSource = imread('DRAW.png');
                    else
                        msgbox("Your Strike went through, play a boost or end your turn to intialize Damage.")
                        app.Image3.ImageSource = imread('DRAW.png');
                        app.StrikeUsed = 1;
                        app.DamagePoints = 1;
                    end
                end
            elseif isequal(app.Image3.ImageSource,imread('Block.png'))
                msgbox("This card will be played automatically when able");
           
            elseif isequal(app.Image3.ImageSource,imread('Potion.png'))
                if app.PlayerNum == 1
                    if app.Player1LPEditField.Value < 3
                        app.Player1LPEditField.Value = app.Player1LPEditField.Value + 1;
                        app.Image3.ImageSource = imread('DRAW.png');
                    else
                        msgbox("You already have your maximum health points")
                    end
                else
                    if app.Player2LPEditField.Value < 3
                        app.Player2LPEditField.Value = app.Player2LPEditField.Value + 1;
                        app.Image3.ImageSource = imread('DRAW.png');
                    else
                        msgbox("You already have your maximum health points")
                    end
                    
                end
                
            elseif isequal(app.Image3.ImageSource,imread('Boost.png'))
                if app.StrikeUsed == 1
                    app.Image3.ImageSource = imread('DRAW.png');
                    app.DamagePoints = app.DamagePoints+1;
                    msgbox("Your damage has been increased")
                else
                    msgbox("This card can only be played if a Strike is played")
                end
                
            else
                msgbox("That is not an available card!")
                app.Image3.ImageSource= imread("DRAW.png");
            end
            
        end

        % Button pushed function: Button_4
        function card4(app, event)
            
            if isequal(app.Image4.ImageSource,imread('Strike.png'))
                if app.StrikeUsed == 1
                    msgbox("You can only use 1 Strike per turn")
                else
                    Blocked = app.DoesItHit();
                    if Blocked == 1
                        msgbox("Your Strike was blocked by the opponent!")
                        app.Image4.ImageSource = imread('DRAW.png');
                    else
                        msgbox("Your Strike went through, play a boost or end your turn to intialize Damage.")
                        app.Image4.ImageSource = imread('DRAW.png');
                        app.StrikeUsed = 1;
                        app.DamagePoints = 1;
                    end
                end
            elseif isequal(app.Image4.ImageSource,imread('Block.png'))
                msgbox("This card will be played automatically when able");
           
            elseif isequal(app.Image4.ImageSource,imread('Potion.png'))
                if app.PlayerNum == 1
                    if app.Player1LPEditField.Value < 3
                        app.Player1LPEditField.Value = app.Player1LPEditField.Value + 1;
                        app.Image4.ImageSource = imread('DRAW.png');
                    else
                        msgbox("You already have your maximum health points")
                    end
                else
                    if app.Player2LPEditField.Value < 3
                        app.Player2LPEditField.Value = app.Player2LPEditField.Value + 1;
                        app.Image4.ImageSource = imread('DRAW.png');
                    else
                        msgbox("You already have your maximum health points")
                    end
                    
                end
                
            elseif isequal(app.Image4.ImageSource,imread('Boost.png'))
                if app.StrikeUsed == 1
                    app.Image4.ImageSource = imread('DRAW.png');
                    app.DamagePoints = app.DamagePoints+1;
                    msgbox("Your damage has been increased")
                else
                    msgbox("This card can only be played if a Strike is played")
                end
                
            else
                msgbox("That is not an available card!")
                app.Image4.ImageSource= imread("DRAW.png");
            end
            
        end

        % Button pushed function: DrawCard2Button
        function drawer2(app, event)
            sixnine=randi(24);
            deck = [1,1,1,1,1,1,1,1,2,2,2,2,3,3,3,3,3,3,3,3,4,4,4,4]; 
        if  isequal(app.Image2.ImageSource,imread("DRAW.png"))
            [y,Fs]=audioread('draw.wav');
            sound(y,Fs);
            switch deck(sixnine)
                case 0 
                    app.Image1.ImageSource = imread('DRAW.png');
                case 1
                    app.Image2.ImageSource = imread('Strike.png');
                    if app.PlayerNum == 1
                        app.MyHand = [app.MyHand,1];
                    else
                        app.OtherHand = [app.OtherHand,1];
                    end
                case 2
                    app.Image2.ImageSource = imread('Block.png');
                    if app.PlayerNum == 1
                        app.MyHand = [app.MyHand,2];
                    else
                        app.OtherHand = [app.OtherHand,2];
                    end
                case 3
                    app.Image2.ImageSource = imread('Potion.png');
                    if app.PlayerNum == 1
                        app.MyHand = [app.MyHand,3];
                    else
                        app.OtherHand = [app.OtherHand,3];
                    end
                case 4
                    app.Image2.ImageSource = imread('Boost.png');
                    if app.PlayerNum == 1
                        app.MyHand = [app.MyHand,4];
                    else
                        app.OtherHand = [app.OtherHand,4];
                    end
            end
            pause(app.WriteDelay);
            if app.PlayerNum == 1
                thingSpeakWrite(app.ChannelID, 'Fields', 1, 'Values', app.MyHand, 'WriteKey', app.WriteKey);
            else
                thingSpeakWrite(app.ChannelID, 'Fields', 2, 'Values', app.OtherHand, 'WriteKey', app.WriteKey);
            end
         end
        end

        % Button pushed function: DrawCard3Button
        function drawer3(app, event)
            sixnine=randi(24);
            deck = [1,1,1,1,1,1,1,1,2,2,2,2,3,3,3,3,3,3,3,3,4,4,4,4]; 
         if  isequal(app.Image3.ImageSource,imread("DRAW.png"))
            [y,Fs]=audioread('draw.wav');
            sound(y,Fs);
             switch deck(sixnine)
                case 0 
                    app.Image1.ImageSource = imread('DRAW.png');
                case 1
                    app.Image3.ImageSource = imread('Strike.png');
                    if app.PlayerNum == 1
                        app.MyHand = [app.MyHand,1];
                    else
                        app.OtherHand = [app.OtherHand,1];
                    end
                case 2
                    app.Image3.ImageSource = imread('Block.png');
                    if app.PlayerNum == 1
                        app.MyHand = [app.MyHand,2];
                    else
                        app.OtherHand = [app.OtherHand,2];
                    end
                case 3
                    app.Image3.ImageSource = imread('Potion.png');
                    if app.PlayerNum == 1
                        app.MyHand = [app.MyHand,3];
                    else
                        app.OtherHand = [app.OtherHand,3];
                    end
                case 4
                    app.Image3.ImageSource = imread('Boost.png');
                    if app.PlayerNum == 1
                        app.MyHand = [app.MyHand,4];
                    else
                        app.OtherHand = [app.OtherHand,4];
                    end
            end
            pause(app.WriteDelay);
            if app.PlayerNum == 1
                thingSpeakWrite(app.ChannelID, 'Fields', 1, 'Values', app.MyHand, 'WriteKey', app.WriteKey);
            else
                thingSpeakWrite(app.ChannelID, 'Fields', 2, 'Values', app.OtherHand, 'WriteKey', app.WriteKey);
            end
         end
        end

        % Button pushed function: DrawCard4Button
        function drawer4(app, event)
            sixnine=randi(24);
            deck = [1,1,1,1,1,1,1,1,2,2,2,2,3,3,3,3,3,3,3,3,4,4,4,4]; 
         if  isequal(app.Image4.ImageSource,imread('DRAW.png'))
            [y,Fs]=audioread('draw.wav');
            sound(y,Fs);
            switch deck(sixnine)
                case 0 
                    app.Image1.ImageSource = imread('DRAW.png');
                case 1
                    app.Image4.ImageSource = imread('Strike.png');
                    if app.PlayerNum == 1
                        app.MyHand = [app.MyHand,1];
                    else
                        app.OtherHand = [app.OtherHand,1];
                    end
                case 2
                    app.Image4.ImageSource = imread('Block.png');
                    if app.PlayerNum == 1
                        app.MyHand = [app.MyHand,2];
                    else
                        app.OtherHand = [app.OtherHand,2];
                    end
                case 3
                    app.Image4.ImageSource = imread('Potion.png');
                    if app.PlayerNum == 1
                        app.MyHand = [app.MyHand,3];
                    else
                        app.OtherHand = [app.OtherHand,3];
                    end
                case 4
                    app.Image4.ImageSource = imread('Boost.png');
                    if app.PlayerNum == 1
                        app.MyHand = [app.MyHand,4];
                    else
                        app.OtherHand = [app.OtherHand,4];
                    end
            end
            pause(app.WriteDelay);
            if app.PlayerNum == 1
                thingSpeakWrite(app.ChannelID, 'Fields', 1, 'Values', app.MyHand, 'WriteKey', app.WriteKey);
            else
                thingSpeakWrite(app.ChannelID, 'Fields', 2, 'Values', app.OtherHand, 'WriteKey', app.WriteKey);
            end
         end
        end

        % Callback function
        function RulesButtonPushed(app, event)
            
        end

        % Button pushed function: RulesButton
        function RulesButtonPushed2(app, event)
            rules = imread('DNA AND.png');
            imshow(rules);
        end

        % Value changed function: Player1LPEditField
        function Player1LPEditFieldValueChanged(app, event)
            value = app.Player1LPEditField.Value;
            if app.PlayerNum == 1
                if app.DamagePoints == 1
                    app.Player1LPEditField.Value = app.Player1LPEditField.Value - 1;
                    [y,Fs]=audioread('lose_health.wav');
                    sound(y,Fs);
                end
                
                if app.DamagePoints == 2
                   app.Player1LPEditField.Value = app.Player1LPEditField.Value - 2;
                   [y,Fs]=audioread('lose_health.wav');
                   sound(y,Fs);
                end
            end
            if app.Image3.ImageSource == imread('Potion.png')
                if app.PlayerNum == 1
                    if app.Player1LPEditField.Value < 3
                    app.Player1LPEditField.Value = app.Player1LPEditField.Value + 1;
                    end
                end
            end
        end

        % Value changed function: Player2LPEditField
        function Player2LPEditFieldValueChanged(app, event)
            value = app.Player2LPEditField.Value;
            if app.PlayerNum == 2
                if app.DamagePoints == 1
                    app.Player2LPEditField.Value = app.Player2LPEditField.Value - 1;
                    [y,Fs]=audioread('lose_health.wav');
                    sound(y,Fs);
                end
                
                if app.DamagePoints == 2
                   app.Player2LPEditField.Value = app.Player2LPEditField.Value - 2;
                   [y,Fs]=audioread('lose_health.wav');
                   sound(y,Fs);
                end
            end
            if app.Image3.ImageSource == imread('Potion.png')
                if app.PlayerNum == 2
                    if app.Player2LPEditField.Value < 3
                    app.Player2LPEditField.Value = app.Player2LPEditField.Value + 1;
                    end
                end
            end
        end

        % Button pushed function: EndTurnButton
        function EndTurnButtonPushed(app, event)
            app.EndTurn();
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.ScaleMethod = 'fill';
            app.Image.Position = [1 1 640 480];
            app.Image.ImageSource = 'background.jpg';

            % Create WhosPlayingButtonGroup
            app.WhosPlayingButtonGroup = uibuttongroup(app.UIFigure);
            app.WhosPlayingButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @WhosPlayingButtonGroupSelectionChanged, true);
            app.WhosPlayingButtonGroup.Title = 'Who''s Playing';
            app.WhosPlayingButtonGroup.Position = [1 408 123 73];

            % Create Player1
            app.Player1 = uiradiobutton(app.WhosPlayingButtonGroup);
            app.Player1.Text = 'Player 1';
            app.Player1.Position = [11 27 66 22];
            app.Player1.Value = true;

            % Create Player2
            app.Player2 = uiradiobutton(app.WhosPlayingButtonGroup);
            app.Player2.Text = 'Player 2';
            app.Player2.Position = [11 5 66 22];

            % Create DrawCard1Button
            app.DrawCard1Button = uibutton(app.UIFigure, 'push');
            app.DrawCard1Button.ButtonPushedFcn = createCallbackFcn(app, @drawed, true);
            app.DrawCard1Button.Icon = 'DRAW.png';
            app.DrawCard1Button.IconAlignment = 'top';
            app.DrawCard1Button.Position = [1 317 98 92];
            app.DrawCard1Button.Text = 'Draw Card 1';

            % Create Player2LPEditFieldLabel
            app.Player2LPEditFieldLabel = uilabel(app.UIFigure);
            app.Player2LPEditFieldLabel.HorizontalAlignment = 'right';
            app.Player2LPEditFieldLabel.Position = [525 317 67 22];
            app.Player2LPEditFieldLabel.Text = 'Player 2 LP';

            % Create Player2LPEditField
            app.Player2LPEditField = uieditfield(app.UIFigure, 'numeric');
            app.Player2LPEditField.ValueChangedFcn = createCallbackFcn(app, @Player2LPEditFieldValueChanged, true);
            app.Player2LPEditField.Editable = 'off';
            app.Player2LPEditField.Position = [607 317 22 22];

            % Create Player1LPEditFieldLabel
            app.Player1LPEditFieldLabel = uilabel(app.UIFigure);
            app.Player1LPEditFieldLabel.HorizontalAlignment = 'right';
            app.Player1LPEditFieldLabel.Position = [525 178 67 22];
            app.Player1LPEditFieldLabel.Text = 'Player 1 LP';

            % Create Player1LPEditField
            app.Player1LPEditField = uieditfield(app.UIFigure, 'numeric');
            app.Player1LPEditField.ValueChangedFcn = createCallbackFcn(app, @Player1LPEditFieldValueChanged, true);
            app.Player1LPEditField.Editable = 'off';
            app.Player1LPEditField.Position = [607 178 21 22];

            % Create StartButton
            app.StartButton = uibutton(app.UIFigure, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.Position = [271 38 100 22];
            app.StartButton.Text = 'Start';

            % Create TextAreaLabel
            app.TextAreaLabel = uilabel(app.UIFigure);
            app.TextAreaLabel.HorizontalAlignment = 'right';
            app.TextAreaLabel.Visible = 'off';
            app.TextAreaLabel.Position = [262 296 56 22];
            app.TextAreaLabel.Text = 'Text Area';

            % Create TextArea
            app.TextArea = uitextarea(app.UIFigure);
            app.TextArea.Editable = 'off';
            app.TextArea.Visible = 'off';
            app.TextArea.Position = [242 263 158 34];
            app.TextArea.Value = {'It is the other Players Turn'};

            % Create ShuffleButton
            app.ShuffleButton = uibutton(app.UIFigure, 'push');
            app.ShuffleButton.ButtonPushedFcn = createCallbackFcn(app, @ShuffleButtonPushed, true);
            app.ShuffleButton.Position = [1 7 100 22];
            app.ShuffleButton.Text = 'Shuffle';

            % Create Image1
            app.Image1 = uiimage(app.UIFigure);
            app.Image1.Position = [149 100 75 100];

            % Create Image3
            app.Image3 = uiimage(app.UIFigure);
            app.Image3.Position = [317 100 75 100];

            % Create Image4
            app.Image4 = uiimage(app.UIFigure);
            app.Image4.Position = [399 100 75 100];

            % Create Image2
            app.Image2 = uiimage(app.UIFigure);
            app.Image2.Position = [233 100 75 100];

            % Create Button
            app.Button = uibutton(app.UIFigure, 'push');
            app.Button.ButtonPushedFcn = createCallbackFcn(app, @card1, true);
            app.Button.Position = [174 80 25 22];
            app.Button.Text = '1';

            % Create Button_2
            app.Button_2 = uibutton(app.UIFigure, 'push');
            app.Button_2.ButtonPushedFcn = createCallbackFcn(app, @card2, true);
            app.Button_2.Position = [260 80 25 22];
            app.Button_2.Text = '2';

            % Create Button_3
            app.Button_3 = uibutton(app.UIFigure, 'push');
            app.Button_3.ButtonPushedFcn = createCallbackFcn(app, @card3, true);
            app.Button_3.Position = [342 80 25 22];
            app.Button_3.Text = '3';

            % Create Button_4
            app.Button_4 = uibutton(app.UIFigure, 'push');
            app.Button_4.ButtonPushedFcn = createCallbackFcn(app, @card4, true);
            app.Button_4.Position = [424 80 25 22];
            app.Button_4.Text = '4';

            % Create DrawCard2Button
            app.DrawCard2Button = uibutton(app.UIFigure, 'push');
            app.DrawCard2Button.ButtonPushedFcn = createCallbackFcn(app, @drawer2, true);
            app.DrawCard2Button.Icon = 'DRAW.png';
            app.DrawCard2Button.IconAlignment = 'top';
            app.DrawCard2Button.Position = [1 225 98 93];
            app.DrawCard2Button.Text = 'Draw Card 2';

            % Create DrawCard3Button
            app.DrawCard3Button = uibutton(app.UIFigure, 'push');
            app.DrawCard3Button.ButtonPushedFcn = createCallbackFcn(app, @drawer3, true);
            app.DrawCard3Button.Icon = 'DRAW.png';
            app.DrawCard3Button.IconAlignment = 'top';
            app.DrawCard3Button.Position = [1 127 98 99];
            app.DrawCard3Button.Text = 'Draw Card 3';

            % Create DrawCard4Button
            app.DrawCard4Button = uibutton(app.UIFigure, 'push');
            app.DrawCard4Button.ButtonPushedFcn = createCallbackFcn(app, @drawer4, true);
            app.DrawCard4Button.Icon = 'DRAW.png';
            app.DrawCard4Button.IconAlignment = 'top';
            app.DrawCard4Button.Position = [1 32 98 96];
            app.DrawCard4Button.Text = 'Draw Card 4';

            % Create EndTurnButton
            app.EndTurnButton = uibutton(app.UIFigure, 'push');
            app.EndTurnButton.ButtonPushedFcn = createCallbackFcn(app, @EndTurnButtonPushed, true);
            app.EndTurnButton.Enable = 'off';
            app.EndTurnButton.Visible = 'off';
            app.EndTurnButton.Position = [541 17 100 22];
            app.EndTurnButton.Text = {'End Turn'; ''};

            % Create RulesButton
            app.RulesButton = uibutton(app.UIFigure, 'push');
            app.RulesButton.ButtonPushedFcn = createCallbackFcn(app, @RulesButtonPushed2, true);
            app.RulesButton.Position = [541 456 100 22];
            app.RulesButton.Text = 'Rules';

            % Create DNAANDLabel
            app.DNAANDLabel = uilabel(app.UIFigure);
            app.DNAANDLabel.FontName = 'we are alien!!';
            app.DNAANDLabel.FontSize = 60;
            app.DNAANDLabel.FontWeight = 'bold';
            app.DNAANDLabel.FontColor = [0.7176 0.2745 1];
            app.DNAANDLabel.Position = [163 330 315 67];
            app.DNAANDLabel.Text = 'DNA AND';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = CardGame8DNAOOWEE

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end