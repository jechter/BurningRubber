unit Tools;
interface
	uses
		Script, Sound, Globals, QDOffScreen,
		Dialogs, ToolUtils, Resources, Menus, Processes, Fonts, gestaltEqu, Palettes, Events, LowMem;

	procedure InitProg;
	procedure InitSound;
	procedure Quit;
	procedure AppDebug (str: Str255);
	procedure DoError (ID: integer);
	procedure HideMenuBar;
	procedure ShowMenuBar;
	procedure ReHideMenuBar;
	procedure EnterHighScore(points:longint);
	procedure DisplayScores;

	function RGB (R, G, B: integer): RGBColor;
	function sign (Numb: integer): Integer;
	procedure OffsetPt(var pt:point;h,v:integer);

implementation
	
	procedure Quit;
		function CheckGameend: boolean;
		begin
			CheckGameend := false;
			if GamePlay then begin		
				if Alert(1003, nil) = 1 then
					CheckGameend := true;
			end else
				CheckGameend := true;
		end;
		
	begin
		if CheckGameEnd then
			begin
				ShowMenuBar;		
				if TheScreen^^.gdType = fixedType then
					TheScreen^^.gdPMap^^.pmTable^^.ctseed := CTOrig;
				if Olddepth<>TheScreen^^.gdPMap^^.pixelsize then
					DoError(SetDepth(TheScreen,OldDepth,0,0));
				ExitToShell;
			end
	end;

	function sign (Numb: integer): Integer;
	begin
		if Numb <> 0 then
			sign := Numb div abs(Numb)
		else
			sign := 1;
	end;

	function RGB (R, G, B: integer): RGBColor;
	begin
		RGB.Red := R;
		RGB.Green := G;
		RGB.Blue := B;
	end;
	
	procedure OffsetPt(var pt:point;h,v:integer);
	begin
		pt.h:=pt.h+h;
		pt.v:=pt.v+v;
	end;


	procedure EffectCallBack (Chan: SndChannelPtr; cmd: SndCommand);
	begin
	end;


	procedure InitSound;
	begin
		BitSet(@ErrFlags, 0);
		if BitTst(@GamePrefs^^.GrafFlags,5) then
			begin
				if (EngineChannel = nil) and not SoundDisable then
					DoError(SndNewChannel(EngineChannel, sampledSynth, initMono + initNoInterp, @EffectCallBack));
				EngineChannel^.userInfo:=longint(GetResource('snd ',2000));
			end;
		if BitTst(@GamePrefs^^.GrafFlags,4) then
			begin	
				if (EffectAChannel = nil) and not SoundDisable then
					DoError(SndNewChannel(EffectAChannel, sampledSynth, initMono, @EffectCallBack));
				if (EffectBChannel = nil) and not SoundDisable then
					DoError(SndNewChannel(EffectBChannel, sampledSynth, initMono, @EffectCallBack));
			end;
		BitClr(@ErrFlags, 0);
	end;
	
	
	procedure Emergency;
	begin
		ExitToShell;
	end;


	procedure InitMac;
		var i:integer;
	begin 
		InitGraf(@qd.thePort);
		InitFonts;
		InitWindows;
		InitMenus;
		TEInit;
		InitDialogs(@Emergency);
		InitCursor;
		MaxApplZone;
		for i:=1 to 64 do
			MoreMasters;
	end;
	
	
	procedure SystemCheck;
	var
		response:longint;
		FastMac:boolean;
	begin
		if TheScreen^^.gdrect.right-TheScreen^^.gdrect.left < 620 then
			begin
				response:=Alert(1005,nil);
				ExitToShell;
			end;
		DoError(Gestalt(gestaltSystemVersion,response));
		if response < $0700 then
			begin
				response:=Alert(1006,nil);
				if response = 1 then
					ExitToShell;
			end;
		DoError(Gestalt(gestaltSoundAttr,response));
		if BitTst(@response,gestaltStereoMixing) then
			SoundDisable:=true;
		FastMac:=false;
		DoError(Gestalt(gestaltSystemVersion,response));
				if response >= $0712 then
				begin
					DoError(Gestalt(gestaltSysArchitecture,response));
					if (response >= gestaltPowerPC) then
						FastMac:=true;
				end;
		DoError(Gestalt(gestaltProcessorType,response));
				if (response>gestalt68030) then
					FastMac:=true;		
		if not FastMac then
			response:=Alert(1011,nil);
		if TheScreen^^.gdPMap^^.pixelSize > 8 then
			begin
				if FastMac and	(HasDepth(TheScreen,8,0,0)<>0) then
					DoError(SetDepth(TheScreen,8,0,0))
				else if (HasDepth(TheScreen,4,0,0)<>0) then
					DoError(SetDepth(TheScreen,4,0,0))
			end;
		if TheScreen^^.gdPMap^^.pixelSize > 4 then
			begin
				if not FastMac and	(HasDepth(TheScreen,4,0,0)<>0) then
					DoError(SetDepth(TheScreen,4,0,0))
			end;
		if TheScreen^^.gdPMap^^.pixelSize < 4 then
			begin
				if not FastMac and (HasDepth(TheScreen,4,0,0)<>0) then
					DoError(SetDepth(TheScreen,4,0,0))
				else if HasDepth(TheScreen,8,0,0)<>0 then
					DoError(SetDepth(TheScreen,8,0,0))
				else begin
					response:=Alert(1008,nil);
					ExitToShell;
				end;
			end;
	end;

	procedure InitProg;
		var 
			NullRect:Rect;
	begin
		InitMac;
		
		TheScreen := GetGDevice;
		OldDepth := GetGDevice^^.gdPMap^^.PixelSize;
		SystemCheck;
		CTorig := TheScreen^^.gdPMap^^.pmTable^^.ctseed;
		Depth := GetGDevice^^.gdPMap^^.PixelSize;
		
		GamePlay := False;

		GamePrefs := PrefHandle(GetResource('SETT', 1000));
		GameKeys := KeyHandle(GetResource('CTLS', 1000));

		ShellWindow := GetNewWindow(1000, nil, Pointer(-1));

		AppleMenu := GetMenu(1000);
		AppendResMenu(AppleMenu, 'DRVR');
		InsertMenu(AppleMenu, 0);
		FileMenu := GetMenu(1001);
		InsertMenu(FileMenu, 0);
		OptMenu := GetMenu(1002);
		InsertMenu(OptMenu, 0);
		DrawMenuBar;

		qd.randseed := TickCount;	
		InitSound;
		
		Sf:=RGB($F000,$F000,$0);
		Sb:=RGB(0,0,0);
		TextFont(0);
		SetRect(NullRect,0,0,1,1);
	end;

	procedure DoError (ID: integer);
		var
			ErrStr: Str255;
			response:integer;
		function Harmless: boolean;
		begin
			Harmless := false;
			if (ID = notEnoughHardwareErr) or (ID = cantOpenHandler)then
				begin
					SetGDevice(TheScreen);
					if BitTst(@ErrFlags, 0) then
						begin
							response := Alert(1002, nil);
							if response = 1 then
								ExitToShell
							else
								begin
									SoundDisable:=TRUE;
									Harmless := true;
								end;
						end;
				end;
			if (ID = memFullErr) or (ID = cNoMemErr) then
				begin
					SetGDevice(TheScreen);
					response := Alert(1001, nil);
					ExitToShell;
				end;
			if (ID=wPrErr) or (ID=flckdErr) then
				begin
					response:=Alert(1010,nil);
					Harmless:=true;
				end;
			if (ID=resproblem) or (ID=badchannel) then Harmless:=true;
		end;
	begin
		if ID<>noErr then
			if not Harmless then
				begin
					SetGDevice(TheScreen);
					NumToString(ID, ErrStr);
					ParamText(ErrStr, '', '', '');
					response := Alert(1000, nil);
					ExitToShell;
				end;
	end;


	procedure AppDebug (str: Str255);
		var
			x: integer;
			GW: GworldPtr;
			GD: GdHandle;
	begin
		getGWorld(GW, GD);
		SetGWorld(CGrafPtr(RaceWindow), TheScreen);
		ParamText(str, '', '', '');
		x := alert(10000, nil);
		SetGWorld(GW, GD);
	end;


	procedure HideMenuBar;
		var
			DrawRect:Rect;
	begin
		if RaceWindow<> nil then
		begin
			SetPort(RaceWindow);
			SetOrigin(0,0);
			RectRgn(RaceWindow^.visRgn,RaceWindow^.portRect);
			SetRect(DrawRect,0,0,RaceWindow^.portRect.right,20);
			FillRect(DrawRect,qd.black);
			LMSetMBarHeight(0);
			SetOrigin(-RaceWindow^.portrect.right div 2+310,-RaceWindow^.portrect.bottom div 2+240);
		end;
	end;
	
	procedure ReHideMenuBar;
	begin
		if RaceWindow<> nil then
		begin
			SetPort(RaceWindow);
			SetOrigin(0,0);
			RectRgn(RaceWindow^.visRgn,RaceWindow^.portRect);
			SetOrigin(-RaceWindow^.portrect.right div 2+310,-RaceWindow^.portrect.bottom div 2+240);
		end;
	end;

	procedure ShowMenuBar;
		var
			VisRect:Rect;
	begin
		if RaceWindow<> nil then
		begin
			SetPort(RaceWindow);
			SetOrigin(0,0);
			SetRect(VisRect,0,20,RaceWindow^.portRect.right,RaceWindow^.portRect.bottom);
			RectRgn(RaceWindow^.visRgn,VisRect);
			SetOrigin(-RaceWindow^.portrect.right div 2+310,-RaceWindow^.portrect.bottom div 2+240);
		end;
		LMSetMBarHeight(20);
		DrawMenuBar;
	end;
	
	
	
	
	
	
	procedure EnterHighScore(points:longint);
		var
			ScoreDlog: DialogPtr;
			ItemData: Handle;
			NameString: Str255;
			hit,i:integer;
			ignore:Rect;
		procedure InsertScore(points:longint;Name:String;place:integer);
			var
				i:integer;
		begin
			for i:= 9 downto place do
				begin
					ScoreHandle(GetResource('HIGH',127+i+1))^^.Score:=ScoreHandle(GetResource('HIGH',127+i))^^.Score;
					ScoreHandle(GetResource('HIGH',127+i+1))^^.Name:=ScoreHandle(GetResource('HIGH',127+i))^^.Name;
					ChangedResource(GetResource('HIGH',127+i+1))
				end;
			ScoreHandle(GetResource('HIGH',127+place))^^.Score:=points;
			ScoreHandle(GetResource('HIGH',127+place))^^.Name:=Name;
			ChangedResource(GetResource('HIGH',127+place));
			DisplayScores;
		end;	
	begin
		FlushEvents(everyEvent,0);
		if not Cheater then
			if points > ScoreHandle(GetResource('HIGH',138))^^.Score then
				begin					
					ScoreDlog := GetNewDialog(2006, nil, Pointer(-1));
					DoError(SetDialogDefaultItem(ScoreDlog, 1));
					SelectDialogItemText(ScoreDlog, 2, 0, maxint);
					repeat
						ModalDialog(nil, hit);
					until hit=1;
					GetDialogItem(ScoreDlog, 2, i, ItemData, ignore);
					GetDialogItemText(ItemData, NameString);
					DisposeDialog(ScoreDlog);	
					for i:= 10 downto 1 do 
						if points < ScoreHandle(GetResource('HIGH',127+i))^^.Score then begin 
							InsertScore(points,NameString,i+1);
							Exit(EnterHighScore);
						end else if i= 1 then
							InsertScore(points,NameString,1)
				end;
	end;

	
	
	procedure DisplayScores;
		var
			ScoreList:DialogPtr;
			ItemData:Handle;
			ScoreString:Str255;
			Hit,i:integer;
			ignore:Rect;
	begin
		ScoreList:=GetNewDialog(2004,nil,Pointer(-1));
		for i := 1 to 10 do
			begin
				GetDialogItem(ScoreList, i+1, Hit, ItemData, ignore);
				SetDialogItemText(ItemData, ScoreHandle(GetResource('HIGH',127+i))^^.Name);
				NumToString(ScoreHandle(GetResource('HIGH',127+i))^^.Score,ScoreString);
				GetDialogItem(ScoreList, i+11, Hit, ItemData, ignore);
				SetDialogItemText(ItemData, Scorestring);
			end;
		Hit:=0;
		while Hit<>1 do
			ModalDialog(nil,Hit);
		DisposeDialog(ScoreList);
	end;

END.