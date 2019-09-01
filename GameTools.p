unit GameTools;
interface
	uses
		 Sound, QDOffscreen, Globals, Tools, GameGlobals,
		 Resources, ToolUtils, Icons, palettes, Fonts;
		 
	function CheckSect (SCR, LRP, tolerance: integer; var Idea: integer): boolean;
	procedure AddUpRect (r: Rect);

	procedure EnterLevel (level: integer);
	procedure DisposeLevel;
	
	procedure DoControl;
		
	procedure ShowMessage (TheMessage: string; h, v, Size: integer);
	procedure ShowBgMessage (TheMessage: string; h, v, Size: integer;bg,fg:RGBColor);
	
	procedure PreLoadSprites;
	procedure FreeSpriteMem(HowMuch:Size);
	procedure PlotSprite (ID: integer; Where: Rect);
	
	procedure BlitToScreen;
	procedure DrawInstr;
	
	procedure SetCLUT;
	procedure ScreenBlood(pro:integer;R,G,B:boolean);
	procedure RemoveBlood(pro:integer);

	procedure KillEngine;
	procedure PlaySound (ID: integer);
	procedure Engine (Speed: integer);


implementation
	var Toggle: boolean;


	procedure SetCLUT;
		var 
			i:integer; 
			OldClut,FadeClut:CtabHandle;
	begin
		if TheScreen^^.gdType <> fixedType then
			begin
				SetGDevice(TheScreen);
				oldClut:=ScreenCT;					
				fadeCLUT := TheScreen^^.gdPMap^^.pmTable;
				
				for i := 0 to fadeClut^^.ctSize do
					begin
						fadeClut^^.ctTable[i].rgb.Red := oldClut^^.ctTable[i].rgb.Red;
						fadeClut^^.ctTable[i].rgb.Blue := oldClut^^.ctTable[i].rgb.Blue;
						fadeClut^^.ctTable[i].rgb.Green := oldClut^^.ctTable[i].rgb.Green;
					end;
				SetEntries(0, fadeClut^^.ctSize - 1, FadeCLUT^^.ctTable);
				StandartCLUT:=True;
			end;
	end;



	procedure ScreenBlood(pro:integer;R,G,B:boolean);
		var fadeClut:ctabhandle;
		i,i2:integer;
	begin
		if TheScreen^^.gdType <> fixedType then
			begin	
				SetGDevice(TheScreen);
				StandartCLUT:=FALSE;
				fadeCLUT := TheScreen^^.gdPMap^^.pmTable;
				for i2:=1 to pro do 
					for i := 0 to fadeClut^^.ctSize do
						begin
							if R then
								begin
									if (fadeClut^^.ctTable[i].rgb.Red > 2000) or (fadeClut^^.ctTable[i].rgb.Red < 0) then
										fadeClut^^.ctTable[i].rgb.Red := fadeClut^^.ctTable[i].rgb.Red - 2000;
								end	
							else 
								if (fadeClut^^.ctTable[i].rgb.Red >= 0) or (fadeClut^^.ctTable[i].rgb.Red < -6000) then
									fadeClut^^.ctTable[i].rgb.Red := fadeClut^^.ctTable[i].rgb.Red + 1000;
									
									
							if G then
								begin
									if (fadeClut^^.ctTable[i].rgb.Green > 2000) or (fadeClut^^.ctTable[i].rgb.Green < 0) then
										fadeClut^^.ctTable[i].rgb.Green := fadeClut^^.ctTable[i].rgb.Green - 2000;
								end	
							else 
								if (fadeClut^^.ctTable[i].rgb.Green >= 0) or (fadeClut^^.ctTable[i].rgb.Green < -6000) then
									fadeClut^^.ctTable[i].rgb.Green := fadeClut^^.ctTable[i].rgb.Green + 1000;
									
									
							if B then
								begin
									if (fadeClut^^.ctTable[i].rgb.Blue > 2000) or (fadeClut^^.ctTable[i].rgb.Blue < 0) then
										fadeClut^^.ctTable[i].rgb.Blue := fadeClut^^.ctTable[i].rgb.Blue - 2000;
								end	
							else 
								if (fadeClut^^.ctTable[i].rgb.Blue >= 0) or (fadeClut^^.ctTable[i].rgb.Blue < -6000) then
									fadeClut^^.ctTable[i].rgb.Blue := fadeClut^^.ctTable[i].rgb.Blue + 1000;
						end;
				SetEntries(0, fadeCLUT^^.ctSize-1, FadeCLUT^^.ctTable);
			end;
	end;
	
	
	procedure RemoveBlood(pro:integer);
		var 
			fadeClut, oldCLUT:ctabhandle;
			i,i2:integer;
	begin
		if TheScreen^^.gdType <> fixedType then
			begin
				SetGDevice(TheScreen);
				oldClut:=GetCTable(1000+Depth);					
				fadeCLUT := TheScreen^^.gdPMap^^.pmTable;
				for i2:=1 to pro do 
					for i := 0 to fadeClut^^.ctSize do
						begin
							if (fadeClut^^.ctTable[i].rgb.Red < oldClut^^.ctTable[i].rgb.Red) or ((fadeClut^^.ctTable[i].rgb.Red < 0) and (oldClut^^.ctTable[i].rgb.Red > 0)) then
								fadeClut^^.ctTable[i].rgb.Red := fadeClut^^.ctTable[i].rgb.Red + 2000
							else
								fadeClut^^.ctTable[i].rgb.Red := oldClut^^.ctTable[i].rgb.Red;
								
								
							if (fadeClut^^.ctTable[i].rgb.Green < oldClut^^.ctTable[i].rgb.Green) or ((fadeClut^^.ctTable[i].rgb.Green < 0) and (oldClut^^.ctTable[i].rgb.Green > 0)) then
								fadeClut^^.ctTable[i].rgb.Green := fadeClut^^.ctTable[i].rgb.Green + 2000
							else
								fadeClut^^.ctTable[i].rgb.Green := oldClut^^.ctTable[i].rgb.Green;
								
								
							if (fadeClut^^.ctTable[i].rgb.Blue < oldClut^^.ctTable[i].rgb.Blue) or ((fadeClut^^.ctTable[i].rgb.Blue < 0) and (oldClut^^.ctTable[i].rgb.Blue > 0)) then
								fadeClut^^.ctTable[i].rgb.Blue := fadeClut^^.ctTable[i].rgb.Blue + 2000
							else
								fadeClut^^.ctTable[i].rgb.Blue := oldClut^^.ctTable[i].rgb.Blue;
						end;
				SetEntries(0, fadeCLUT^^.ctSize - 1, FadeCLUT^^.ctTable);
			end;
	end;


	procedure AddUpRect (r: Rect);
	begin
		RectCount := RectCount + 1;
		URects[rectCount] := r;
	end;




	procedure DrawInstr;
		var
			DrawRect:Rect;
			ScoreString, NumStr: Str255;
			myIcon:CIconHandle;
	begin
		SetPort(RaceWindow);
		SetGWorld(CGrafPtr(RaceWindow),nil);	
		SetRect(DrawRect, 0, 480 - 100, 100, 480);
		DrawPicture(GetPicture(1000), DrawRect);
		SetRect(DrawRect, 100, 480 - 32, 620 , 480);
		myIcon:=GetCIcon(1000);
		PlotCIcon(DrawRect,myIcon);
		DisposeCIcon(myIcon);
		SetRect(DrawRect,310,480-28,610,480+2);
		DrawPicture(GetPicture(1001), DrawRect);

		GetIndString(ScoreString, 2000, 5);
		ShowBgMessage(ScoreString, 620 - 210,480-10, 12,Sb,Sf);

		GetIndString(ScoreString, 2000, 2);
		NumToString(Lives, NumStr);
		ShowBgMessage(ScoreString, 620 - 290,480-10, 12,Sb,Sf);
		ShowBgMessage(NumStr, 620 - 250, 480-10, 12,Sb,Sf);
			
		GetIndString(ScoreString, 2000, 1);
		NumToString(Score, NumStr);
		ShowBgMessage(ScoreString, 620 - 110, 480-10, 12,Sb,Sf);
		ShowBgMessage(NumStr, 620 - 65, 480-10, 12,Sb,Sf);	
			
		if (MultiBonus < 0)then
			begin	
				SetRect(DrawRect, 620 - 135, 480-22, 620 - 117, 480-4);
				myIcon:=GetCIcon(1040 + abs(multiBonus));
				PlotCIcon(DrawRect,myIcon);
				DisposeCicon(myIcon);	
			end;							
	end;
	
	

	





		
	procedure BlitToScreen;
		var BlitRect:Rect;
	begin
		if TheScreen^^.gdPMap^^.pmTable^^.ctseed <> GetGworldPixMap(Screenworld)^^.pmTable^^.ctseed	then
				begin
					if StandartClut then
						SetCLUT;
					TheScreen^^.gdPMap^^.pmTable^^.ctseed := GetGworldPixMap(Screenworld)^^.pmTable^^.ctseed;
				end;
		SetRect(BlitRect, 0, 0, 620, 480 - 100);
		SetGWorld(CGrafPtr(RaceWindow), TheScreen);
		CopyBits(BitMapHandle(GetGWorldPixMap(Screenworld))^^, RaceWindow^.portbits, BlitRect, BlitRect, srcCopy, nil);
		SetRect(BlitRect, 0, 480 - 100, 620, 480 - 20);
		CopyBits(BitMapHandle(GetGWorldPixMap(Screenworld))^^, RaceWindow^.portbits, BlitRect, BlitRect, srcCopy, clip);
	end;
	
	

	function CheckSect (SCR, LRP, tolerance: integer; var Idea: integer): boolean;
	begin
		if SCR > 0 then
			begin
				if (Data^^[SCR][1] + tolerance >= LRP) then
					begin
						CheckSect := true;
						Idea := 1;
					end
				else if (Data^^[SCR][4] - tolerance <= LRP) then
					begin
						CheckSect := true;
						Idea := -1;
					end
				else if ((Data^^[SCR][2] - tolerance <= LRP) and (Data^^[SCR][2] <> Data^^[SCR][3]) and (Data^^[SCR][3] + tolerance >= LRP)) then
					begin
						CheckSect := true;
						if LRP - Data^^[SCR][2] < Data^^[SCR][3] - LRP then
							Idea := -1
						else
							Idea := 1;
					end
				else
					CheckSect := False;
			end
		else
			CheckSect := False;
	end;



	procedure EnterLevel (level: integer);
		var
			i: integer;
			DrawingRect:Rect;
	begin
		Scroll := 0;
		BackScroll := 0;
		Jump := 0;
		MaxJump := 0;
		OldScroll := -240;
		LastObj := 0;
		CarDirection := 0;
		Wait := 45;
		OldSpeed := 0;
		UDSpeed := 0;
		LRSpeed := 0;
		UDPos := 480 - GamePrefs^^.Offset - 16;
		LRPos := (310) - 16;
		for i := 1 to 10 do
			Animations[i].on := False;
		for i := 1 to 100 do
			ItemInfo[i] := ObjSoft(0);
		DeadCount := 0;
		Dead := false;
		BrakeDone := true;
		DoneCount := 0;
		oldBonus:=-1;
		GamePause:=false;
		SetRect(CarRect,0,0,0,0);
		
		Info := LevelHandle(GetResource('INFO', 1000 - 1 + Level mod 10));
		RoadColData:=GetResource('CCOL',Info^^.RoadID);
		Rebirthes := RebHandle(GetResource('RSET', Info^^.DataID));
		MyRoad := RoadHandle(GetResource('ROAD', Info^^.RoadID));
		Items := ObHandle(GetResource('OBJS', Info^^.ObjID));
		Data := DataHandle(GetResource('LEVL', Info^^.DataID));
		for i:=1 to ((Level-1) div 10) do
			Info^^.Bonus:=Info^^.Bonus-120 div i;
		
		MultiBonus := abs(random mod 3) + 1;
		BonPos := trunc(abs(random) * ((Info^^.Stopat - 360) / maxint))+200;
		if not (Data^^[BonPos][2] = Data^^[BonPos][3]) then
			if Data^^[BonPos][2] - Data^^[BonPos][1] > Data^^[BonPos][4] - Data^^[BonPos][3] then
				BonLR := Data^^[BonPos][1] + (Data^^[BonPos][2] - Data^^[BonPos][1]) div 2 - 16
			else
				BonLR := Data^^[BonPos][3] + (Data^^[BonPos][4] - Data^^[BonPos][3]) div 2 - 16
		else
			BonLR := Data^^[BonPos][1] + (Data^^[BonPos][4] - Data^^[BonPos][1]) div 2;
		DrawInstr;

		if BitTst(@GamePrefs^^.GrafFlags, 3) then
			begin
				SetGworld(BackWorld, nil);
				SetRect(DrawingRect, 0, -44, GamePrefs^^.TextureSize, 480);
				FillCRect(DrawingRect, GetPixPat(MyRoad^^.BackPat));
			end;
	end;

	procedure DisposeLevel;
	begin
		HUnLock(Handle(EffectAChannel^.userInfo));
		HUnLock(Handle(EffectBChannel^.userInfo));
		ReleaseResource(Handle(Info));
		ReleaseResource(Handle(Rebirthes));
		ReleaseResource(Handle(Items));
		ReleaseResource(Handle(MyRoad));
		ReleaseResource(Handle(Data));
	end;



	procedure DoControl;
		var
			Keys: packed array[1..128] of boolean;
	begin
		GetKeys(KeyMap(Keys));
		AccKey := Keys[GameKeys^^.AccCode];
		BrakKey := Keys[GameKeys^^.BrakCode];
		LKey := Keys[GameKeys^^.LCode];
		RKey := Keys[GameKeys^^.RCode];
	end;


	procedure ShowMessage (TheMessage: string; h, v, Size: integer);
		var
			update: Rect;
	begin
		TextSize(Size);
		TextFont(systemFont);
		RGBForeColor(RGB(1074,2015,21724));
		SetRect(Update, h, v - Size, h + StringWidth(TheMessage), v + Size div 4);
		AddUpRect(update);
		MoveTo(h, v);
		DrawString(TheMessage);
		ForeColor(BlackColor);
	end;
	
	procedure ShowBgMessage (TheMessage: string; h, v, Size: integer;bg,fg:RGBColor);
	begin
		TextSize(Size);
		TextMode(srcCopy);
		TextFont(200);
		RGBBackColor(bg);
		RGBForeColor(fg);
		MoveTo(h, v);
		DrawString(TheMessage);
		TextSize(12);
		TextMode(srcOr);
		BackColor(WhiteColor);
		ForeColor(BlackColor);
	end;
	
	
	
	
	procedure LoadSprite(ID:integer);
		var myIcon:CiconHandle;
	begin
		if (Sprites[ID].SpriteWorld=nil) then begin
			myIcon := GetCIcon(ID);
			ReleaseResource(GetResource('cicn',ID));
			Sprites[ID].MaskPort:=GrafPtr(NewPtr(sizeOf(GrafPort)));
			OpenPort(Sprites[ID].MaskPort);
			Sprites[ID].MaskPort^.portBits.bounds:=myIcon^^.iconMask.bounds;
			Sprites[ID].MaskPort^.portBits.rowbytes:=myIcon^^.iconMask.rowbytes;
			Sprites[ID].MaskPort^.portBits.baseAddr:=NewPtr(myIcon^^.iconMask.rowbytes*(myIcon^^.iconMask.bounds.bottom-myIcon^^.iconMask.bounds.top));
			SetPort(Sprites[ID].MaskPort);
			PlotCIcon(myIcon^^.iconMask.bounds,myIcon);	
			
			DoError(NewGWorld(Sprites[ID].SpriteWorld, Depth, Sprites[ID].MaskPort^.portBits.bounds, ScreenCT, nil, 0));
			SetGWorld(Sprites[ID].SpriteWorld,nil);
			if LockPixels(GetGWorldPixMap(Sprites[ID].SpriteWorld)) then
				PlotCIcon(Sprites[ID].MaskPort^.portBits.bounds,myIcon);
			UnlockPixels(GetGWorldPixMap(Sprites[ID].SpriteWorld));	
						
			DisposeCIcon(myIcon);
			SetGWorld(Screenworld,nil);
		end;
	end;
	
	procedure DisposeSprite(ID:integer);
	begin
		if Sprites[ID].SpriteWorld<>nil then
			begin
				DisposeGWorld(Sprites[ID].SpriteWorld);
				Sprites[ID].SpriteWorld:=nil;
				DisposePtr(Sprites[ID].MaskPort^.portBits.baseAddr);
				ClosePort(Sprites[ID].MaskPort);
			end;
	end;
	
	
	
	procedure PreLoadSprites;
		type 
			list=array[1..maxint] of integer;
			ListPtr=^List;
			ListHandle=^ListPtr;
		var 
			count:integer;
			LoadList:listHandle;
			Cursors:array [1..4] of CCrsrHandle;
	begin
		for count:=1 to 4 do
			begin
				Cursors[count]:=GetCCursor(1000-1+count);
				ReleaseResource(GetResource('crsr',1000-1+count));
			end;
		LoadList:=ListHandle(GetResource('PrLd',1000));
		count:=1;
		ShowCursor;
		while count*2<=GetHandleSize(Handle(LoadList)) do 
		begin
			SetCCursor(Cursors[count mod 4+1]);
			LoadSprite(LoadList^^[count]);
			count:=count+1;
		end;
		SetCursor(qd.arrow);
		ObscureCursor;
	end;
	
	
	procedure FreeSpriteMem(HowMuch:Size);
		type 
			list=array[1..maxint] of integer;
			ListPtr=^List;
			ListHandle=^ListPtr;
		var 
			count:integer;
			DispList:listHandle;
	begin
		DispList:=ListHandle(GetResource('PrLd',2000));
		count:=0;
		while (FreeMem<HowMuch) and (count<100) do
			begin
				DisposeSprite(DispList^^[abs(random mod 103)+1]);
				count:=count+1;
			end;
	end;
	
	
	
	procedure PlotSprite (ID: integer; Where: Rect);
		var
			ScreenSize: Rect;
		begin
		SetRect(ScreenSize, 0, 0, 620, 480);
		if SectRect(Where, ScreenSize, ScreenSize) then
			begin
				if Sprites[ID].SpriteWorld= nil  then
					LoadSprite(ID);
				GetGWorldPixmap(Sprites[ID].SpriteWorld)^^.pmTable^^.ctseed:=GetGWorldPixmap(Screenworld)^^.pmTable^^.ctseed;
				CopyMask(BitMapHandle(GetGworldPixMap(Sprites[ID].SpriteWorld))^^, Sprites[ID].MaskPort^.portBits, BitMapHandle(GetGworldPixMap(Screenworld))^^, Sprites[ID].MaskPort^.portBits.bounds, Sprites[ID].MaskPort^.portBits.bounds, where) 
			end;
	end;

	
	
	
	procedure PlaySound (ID: integer);
		var
			Chan: SndChannelPtr;
			Com: sndCommand;
	begin
		if BitTst(@GamePrefs^^.GrafFlags,4) and not SoundDisable then
			begin
				if Toggle = True then
					chan := EffectAChannel
				else
					chan := EffectBChannel;
				com.cmd:=quietcmd;
				DoError(SndDoImmediate(chan, com));
				HUnLock(Handle(chan^.userInfo));
				HLock(GetResource('snd ',ID));
				DoError(SndPlay(chan, sndListHandle(GetResource('snd ',ID)), True));
				chan^.userInfo:=longint(GetResource('snd ',ID));
				if Toggle = True then
					Toggle := False
				else
					Toggle := True;
			end;
	end;

	procedure Engine (Speed: integer);
		var 
			cmd: sndCommand;
	begin
		if BitTst(@GamePrefs^^.GrafFlags,5) and not SoundDisable then
			begin
				cmd.cmd:=FlushCmd;
				DoError(SndDoImmediate(EngineChannel, cmd));
				cmd.cmd := RateCmd;
				cmd.Param2 := round(((speed+random mod 2) / 50) * 8000 + 1000);
				DoError(SndDoImmediate(EngineChannel, cmd));
				cmd.cmd := ampCmd;
				cmd.Param1 := round(((speed+random mod 3) / 50) * 205 + 50);
				DoError(SndDoImmediate(EngineChannel, cmd));
				if Speed<>0 then
				DoError(SndPlay(EngineChannel, sndListHandle(EngineChannel^.userInfo), True));
			end;
	end;
	
	procedure KillEngine;
		var 
			cmd: sndCommand;
	begin
		cmd.cmd:=quietCmd;
		DoError(SndDoImmediate(EngineChannel, cmd));
	end;
end.